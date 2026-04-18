#ifndef RNG_H
#define RNG_H

#include <stdint.h>

/*
 * xoshiro256+ PRNG with per-stream independence.
 *
 *   Blackman & Vigna, "Scrambled Linear Pseudorandom Number Generators",
 *   ACM TOMS 47 (2021). See https://prng.di.unimi.it/.
 *
 * Public API:
 *   rng_init(r, seed, stream)  seed via splitmix64, then advance
 *                              stream * 2^128 steps so that different
 *                              `stream` values give non-overlapping,
 *                              statistically independent sequences.
 *   rng_uniform(r)             next uniform double in [-1, 1).
 *
 * rng_init (splitmix + 2^128 jump table) lives in rng.c. rng_uniform and
 * its xoshiro core step are `static inline` here so that the Monte Carlo
 * inner loop pays zero call overhead.
 */

typedef struct {
    uint64_t s[4];
} Rng;

void rng_init(Rng* r, uint64_t seed, int stream);

static inline uint64_t rng_rotl64(uint64_t x, int k)
{
    return (x << k) | (x >> (64 - k));
}

/* xoshiro256+ core step: advance state and return a 64-bit sample. */
static inline uint64_t rng_next_u64(Rng* r)
{
    const uint64_t res = rng_rotl64(r->s[0] + r->s[3], 23) + r->s[0];
    const uint64_t t = r->s[1] << 17;
    r->s[2] ^= r->s[0];
    r->s[3] ^= r->s[1];
    r->s[1] ^= r->s[2];
    r->s[0] ^= r->s[3];
    r->s[2] ^= t;
    r->s[3] = rng_rotl64(r->s[3], 45);
    return res;
}

/* Top 53 bits -> double in [0, 1); rescaled to [-1, 1). */
static inline double rng_uniform(Rng* r)
{
    const double scale = 2.0 / (double)(UINT64_C(1) << 53);
    return (double)(rng_next_u64(r) >> 11) * scale - 1.0;
}

#endif
