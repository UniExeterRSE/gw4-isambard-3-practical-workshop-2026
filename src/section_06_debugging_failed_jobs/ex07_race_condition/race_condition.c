/* race_condition.c
 *
 * A two-level loop that counts integers in [0, N) x [0, M) divisible by 3.
 * The outer loop is parallelised with OpenMP, but the accumulation into `hits`
 * is a data race: multiple threads write to the same variable without a
 * reduction clause.
 *
 * Expected result: number of integers in [0, N*M) divisible by 3
 * Actual result:   non-deterministic — almost always gives the wrong answer.
 */
#define _POSIX_C_SOURCE 200809L

#include <omp.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv)
{
    int N = (argc > 1) ? atoi(argv[1]) : 4000;
    int M = (argc > 2) ? atoi(argv[2]) : 4000;

    long expected = ((long)N * M - 1) / 3 + 1; /* count of multiples of 3 in [0, N*M) */
    long hits = 0;

#pragma omp parallel for schedule(static)
    for (int i = 0; i < N; i++) {
        long row_hits = 0;
        for (int j = 0; j < M; j++) {
            if ((i * M + j) % 3 == 0)
                row_hits++;
        }
        hits += row_hits;
    }

    printf("threads=%d  N=%d  M=%d\n", omp_get_max_threads(), N, M);
    printf("expected \xe2\x89\x88 %ld\n", expected);
    printf("got        %ld\n", hits);
    printf("correct?   %s\n", (hits == expected) ? "yes" : "NO \xe2\x80\x94 race condition detected!");
    return (hits == expected) ? 0 : 1;
}
