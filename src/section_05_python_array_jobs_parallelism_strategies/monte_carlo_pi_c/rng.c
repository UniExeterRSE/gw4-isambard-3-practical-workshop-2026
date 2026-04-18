#include "rng.h"

/*
 * splitmix64 — maps any 64-bit seed to a well-distributed 256-bit state.
 * This is what xoshiro's authors recommend for seeding from a single value.
 */
static void splitmix_seed(Rng* r, uint64_t seed)
{
    for (int i = 0; i < 4; i++) {
        seed += 0x9e3779b97f4a7c15ULL;
        uint64_t z = seed;
        z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9ULL;
        z = (z ^ (z >> 27)) * 0x94d049bb133111ebULL;
        r->s[i] = z ^ (z >> 31);
    }
}

/*
 * Jump 2^128 steps through the xoshiro256+ sequence. Calling this N times
 * produces N non-overlapping streams each 2^128 values long — far more
 * than enough for any practical per-thread sample budget.
 *
 * The jump polynomial J[] is fixed by the xoshiro256+ recurrence; see
 * https://prng.di.unimi.it/xoshiro256plus.c.
 */
static void xoshiro_jump(Rng* r)
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
            (void)rng_next_u64(r);
        }
    }
    r->s[0] = ns[0];
    r->s[1] = ns[1];
    r->s[2] = ns[2];
    r->s[3] = ns[3];
}

void rng_init(Rng* r, uint64_t seed, int stream)
{
    splitmix_seed(r, seed);
    for (int i = 0; i < stream; i++)
        xoshiro_jump(r);
}
