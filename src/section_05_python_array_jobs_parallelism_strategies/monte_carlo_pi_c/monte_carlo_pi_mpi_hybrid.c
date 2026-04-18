/*
 * monte_carlo_pi_mpi_hybrid.c
 *
 * Monte Carlo estimation of pi via the volume ratio of a unit d-sphere to its
 * enclosing d-cube [-1,1]^d.  MPI distributes samples across ranks; OpenMP
 * parallelises within each rank.
 *
 * Memory layout — SoA chunks: coords[d][chunk_size] ensures each dimension's
 * data is contiguous, so the per-dimension accumulation loop over chunk_size
 * samples is a simple stride-1 fused-multiply-add that auto-vectorises.  Each
 * row in the SoA block is padded to a cache-line boundary so aligned loads
 * are valid for every dimension.
 *
 * RNG — xoshiro256+: seeded per rank via splitmix64, then each OpenMP thread
 * jumps 2^128 steps ahead for statistically independent streams.
 *
 * Target: NVIDIA Grace (Neoverse V2, SVE2, 64-byte cache line).  Build:
 *   mpicc -O3 -march=native -fopenmp -std=c11 \
 *         monte_carlo_pi_mpi_hybrid.c -o monte_carlo_pi_mpi_hybrid -lm
 *
 * On x86 dev with conda-forge mpicc (needs CC override):
 *   OMPI_CC=gcc mpicc -O3 -march=native -fopenmp -std=c11 \
 *         monte_carlo_pi_mpi_hybrid.c -o monte_carlo_pi_mpi_hybrid -lm
 */

/* M_PI and tgamma are POSIX/GNU extensions not in strict C11. */
#define _GNU_SOURCE

#include <getopt.h>
#include <math.h>
#include <mpi.h>
#include <omp.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ── alignment constants ─────────────────────────────────────────────── */

/* 64 bytes matches both x86 and ARM Neoverse cache lines. */
#define CACHE_LINE 64
#define DBL_PER_LINE (CACHE_LINE / sizeof(double)) /* 8 */

/* ── xoshiro256+ RNG ─────────────────────────────────────────────────── */

typedef struct {
    uint64_t s[4];
} Rng;

static inline uint64_t rotl64(const uint64_t x, const int k)
{
    return (x << k) | (x >> (64 - k));
}

static inline uint64_t rng_next(Rng* restrict r)
{
    const uint64_t res = rotl64(r->s[0] + r->s[3], 23) + r->s[0];
    const uint64_t t = r->s[1] << 17;
    r->s[2] ^= r->s[0];
    r->s[3] ^= r->s[1];
    r->s[1] ^= r->s[2];
    r->s[0] ^= r->s[3];
    r->s[2] ^= t;
    r->s[3] = rotl64(r->s[3], 45);
    return res;
}

/* Map a uint64 to a double in [-1, 1) using the top 53 bits. */
static inline double rng_uniform(Rng* restrict r)
{
    return (double)(rng_next(r) >> 11) * (2.0 / (double)(UINT64_C(1) << 53)) - 1.0;
}

/* Seed via splitmix64 so any uint64 produces a well-distributed state. */
static void rng_seed(Rng* r, uint64_t v)
{
    for (int i = 0; i < 4; i++) {
        v += 0x9e3779b97f4a7c15ULL;
        uint64_t z = v;
        z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9ULL;
        z = (z ^ (z >> 27)) * 0x94d049bb133111ebULL;
        r->s[i] = z ^ (z >> 31);
    }
}

/* Jump 2^128 steps — call once per thread offset for independent streams. */
static void rng_jump(Rng* r)
{
    static const uint64_t J[4] = {
        0x180ec6d33cfd0abaULL,
        0xd5a61266f0c9392cULL,
        0xa9582618e03fc9aaULL,
        0x39abdc4529b1661cULL,
    };
    uint64_t ns[4] = { 0, 0, 0, 0 };
    for (int i = 0; i < 4; i++) {
        for (int b = 0; b < 64; b++) {
            if (J[i] & (UINT64_C(1) << b)) {
                ns[0] ^= r->s[0];
                ns[1] ^= r->s[1];
                ns[2] ^= r->s[2];
                ns[3] ^= r->s[3];
            }
            rng_next(r);
        }
    }
    r->s[0] = ns[0];
    r->s[1] = ns[1];
    r->s[2] = ns[2];
    r->s[3] = ns[3];
}

/* ── analytic quantities ─────────────────────────────────────────────── */

/* Hit probability p = Vol(d-sphere) / Vol(d-cube) = pi^(d/2) / (Gamma(d/2+1) * 2^d) */
static double analytic_p(int d)
{
    return pow(M_PI, d * 0.5) / (tgamma(d * 0.5 + 1.0) * pow(2.0, d));
}

/* Invert p → pi estimate: pi = (2^d * Gamma(d/2+1) * p)^(2/d) */
static double p_to_pi(double p, int d)
{
    return pow(pow(2.0, d) * tgamma(d * 0.5 + 1.0) * p, 2.0 / d);
}

/* ── core kernel ─────────────────────────────────────────────────────── */

/*
 * Count how many of `n` uniform random points in [-1,1]^d land inside the
 * unit d-sphere.  Works in chunks to bound peak memory usage.
 *
 * `padded_chunk` must be a multiple of DBL_PER_LINE (8) so that each
 * row coords[j * padded_chunk] is CACHE_LINE-aligned.
 */
static long long count_hits(long long n, int d, long long padded_chunk, Rng* rng)
{
    double* coords = (double*)aligned_alloc(
        CACHE_LINE, (size_t)d * (size_t)padded_chunk * sizeof(double));
    double* rsq = (double*)aligned_alloc(CACHE_LINE, (size_t)padded_chunk * sizeof(double));
    if (!coords || !rsq) {
        fprintf(stderr, "OOM allocating %lld-element chunk (d=%d)\n", padded_chunk, d);
        abort();
    }

    long long hits = 0, rem = n;

    while (rem > 0) {
        long long m = (rem < padded_chunk) ? rem : padded_chunk;

        /* Fill coords in SoA order: coords[j * padded_chunk + i] = uniform(-1,1). */
        for (int j = 0; j < d; j++) {
            double* cj = coords + (size_t)j * (size_t)padded_chunk;
            for (long long i = 0; i < m; i++)
                cj[i] = rng_uniform(rng);
        }

        /* Zero radius-squared scratch. */
        memset(rsq, 0, (size_t)m * sizeof(double));

        /* Accumulate x_j^2 for each dimension — inner loop is pure stride-1 FMA. */
        for (int j = 0; j < d; j++) {
            const double* restrict cj = (const double*)__builtin_assume_aligned(
                coords + (size_t)j * (size_t)padded_chunk, CACHE_LINE);
            double* restrict rq = (double*)__builtin_assume_aligned(rsq, CACHE_LINE);
#pragma omp simd aligned(cj : CACHE_LINE) aligned(rq : CACHE_LINE)
            for (long long i = 0; i < m; i++)
                rq[i] += cj[i] * cj[i];
        }

        /* Count in-sphere samples. */
        long long ch = 0;
        const double* restrict rq = (const double*)__builtin_assume_aligned(rsq, CACHE_LINE);
#pragma omp simd reduction(+ : ch) aligned(rq : CACHE_LINE)
        for (long long i = 0; i < m; i++)
            ch += (rq[i] <= 1.0);
        hits += ch;

        rem -= m;
    }

    free(coords);
    free(rsq);
    return hits;
}

/* ── per-rank driver: fan out across OMP threads ─────────────────────── */

static long long count_local_hits(
    long long local_n, int d, long long chunk_size,
    uint64_t base_seed, int num_threads)
{
    /* Round chunk_size up to multiple of DBL_PER_LINE so all SoA rows align. */
    long long padded = ((chunk_size + (long long)DBL_PER_LINE - 1) / (long long)DBL_PER_LINE)
        * (long long)DBL_PER_LINE;

    long long total_hits = 0;

#pragma omp parallel num_threads(num_threads) reduction(+ : total_hits)
    {
        int tid = omp_get_thread_num();
        int nthreads = omp_get_num_threads();

        /* Each thread gets an independent RNG stream via 2^128 jump per slot. */
        Rng rng;
        rng_seed(&rng, base_seed);
        for (int i = 0; i <= tid; i++)
            rng_jump(&rng);

        /* Slice samples evenly across threads. */
        long long start = (local_n * (long long)tid) / (long long)nthreads;
        long long end = (local_n * (long long)(tid + 1)) / (long long)nthreads;

        total_hits += count_hits(end - start, d, padded, &rng);
    }

    return total_hits;
}

/* ── CLI ─────────────────────────────────────────────────────────────── */

typedef struct {
    long long n;
    int d;
    long long chunk_size;
    uint64_t seed;
    int num_threads;
} Config;

static void usage(const char* prog)
{
    fprintf(stderr,
        "Usage: %s [options]\n"
        "  -n <samples>   total samples      (default 200000)\n"
        "  -d <dims>      dimensions         (default 2)\n"
        "  -c <chunk>     chunk size         (default 65536)\n"
        "  -s <seed>      RNG seed           (default 20260421)\n"
        "  -t <threads>   OMP threads/rank   (default: OMP_NUM_THREADS or 1)\n"
        "  -h             show this help\n",
        prog);
}

static int parse_args(int argc, char* argv[], Config* cfg)
{
    int default_threads = 1;
    const char* e = getenv("OMP_NUM_THREADS");
    if (e && atoi(e) > 0)
        default_threads = atoi(e);

    cfg->n = 200000LL;
    cfg->d = 2;
    cfg->chunk_size = 65536LL;
    cfg->seed = 20260421ULL;
    cfg->num_threads = default_threads;

    int opt;
    while ((opt = getopt(argc, argv, "n:d:c:s:t:h")) != -1) {
        switch (opt) {
        case 'n':
            cfg->n = atoll(optarg);
            break;
        case 'd':
            cfg->d = atoi(optarg);
            break;
        case 'c':
            cfg->chunk_size = atoll(optarg);
            break;
        case 's':
            cfg->seed = (uint64_t)atoll(optarg);
            break;
        case 't':
            cfg->num_threads = atoi(optarg);
            break;
        case 'h':
            usage(argv[0]);
            return 1;
        default:
            usage(argv[0]);
            return 2;
        }
    }

    if (cfg->n < 1 || cfg->d < 1 || cfg->chunk_size < 1 || cfg->num_threads < 1) {
        fprintf(stderr, "All numeric arguments must be >= 1\n");
        usage(argv[0]);
        return 2;
    }
    return 0;
}

/* ── main ────────────────────────────────────────────────────────────── */

int main(int argc, char* argv[])
{
    int provided;
    MPI_Init_thread(&argc, &argv, MPI_THREAD_FUNNELED, &provided);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    Config cfg;
    int rc = parse_args(argc, argv, &cfg);
    if (rc != 0) {
        MPI_Finalize();
        return (rc == 1) ? 0 : 1;
    }

    /* Distribute samples: lower ranks absorb the remainder. */
    long long local_n = cfg.n / (long long)size;
    if ((long long)rank < (cfg.n % (long long)size))
        local_n++;

    /* Offset seed per rank so rank-level streams are also distinct. */
    uint64_t rank_seed = cfg.seed + (uint64_t)rank * 10000ULL;

    MPI_Barrier(MPI_COMM_WORLD);
    double t0 = MPI_Wtime();

    long long local_hits = count_local_hits(
        local_n, cfg.d, cfg.chunk_size, rank_seed, cfg.num_threads);

    double elapsed = MPI_Wtime() - t0;

    long long total_hits = 0, total_n = 0;
    double max_elapsed = 0.0;
    MPI_Reduce(&local_hits, &total_hits, 1, MPI_LONG_LONG_INT, MPI_SUM, 0, MPI_COMM_WORLD);
    MPI_Reduce(&local_n, &total_n, 1, MPI_LONG_LONG_INT, MPI_SUM, 0, MPI_COMM_WORLD);
    MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        double p_hat = (double)total_hits / (double)total_n;
        double p_true = analytic_p(cfg.d);
        double sigma_p = sqrt(p_true * (1.0 - p_true) / (double)total_n);
        double pi_hat = p_to_pi(p_hat, cfg.d);
        /* Delta-method std of pi: |d(pi)/d(p)| * sigma_p = (2/d) * pi/p * sigma_p */
        double sigma_pi = (2.0 / cfg.d) * (M_PI / p_true) * sigma_p;

        printf("d=%d N=%lld num_threads=%d seed=%llu mpi_ranks=%d\n",
            cfg.d, total_n, cfg.num_threads,
            (unsigned long long)cfg.seed, size);

        /* Header matches Python's print_results format. */
        const char* hdr = "variant             hits      p_hat     p_true    sigma_p"
                          "     pi_hat   sigma_pi   thr ranks    time[s]";
        printf("%s\n", hdr);
        for (int i = 0; hdr[i]; i++)
            putchar('-');
        putchar('\n');

        printf("%-16s %12lld %10.6f %10.6f %10.6f %10.6f %10.6f %5d %5d %10.4f\n",
            "c-mpi-omp",
            total_hits,
            p_hat,
            p_true,
            sigma_p,
            pi_hat,
            sigma_pi,
            cfg.num_threads,
            size,
            max_elapsed);
    }

    MPI_Finalize();
    return 0;
}
