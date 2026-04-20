from __future__ import annotations

import argparse
import math
import os
import time
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class ExperimentConfig:
    d: int
    n: int
    num_threads: int
    seed: int
    chunk_size: int = 262_144  # 2**18
    save: str | None = None


@dataclass(frozen=True)
class ExperimentResult:
    variant: str
    hits: int
    n: int
    d: int
    hit_probability: float
    analytic_probability: float
    analytic_probability_std: float
    pi_estimate: float
    analytic_pi_std: float
    elapsed_s: float
    num_threads: int
    mpi_processes: int


def default_num_threads() -> int:
    return max(
        1,
        int(
            os.environ.get(
                "NUM_THREADS",
                os.environ.get("NUMBA_NUM_THREADS", "1"),
            )
        ),
    )


def chunk_lengths(n: int, chunk_size: int) -> list[int]:
    return [min(chunk_size, n - start) for start in range(0, n, chunk_size)]


def unit_sphere_volume(d: int) -> float:
    if d < 1:
        raise ValueError("d must be a positive integer.")
    return math.pi ** (d / 2.0) / math.gamma(d / 2.0 + 1.0)


def analytic_hit_probability(d: int) -> float:
    return unit_sphere_volume(d) / (2.0**d)


def analytic_probability_stats(d: int, n: int) -> tuple[float, float]:
    probability = analytic_hit_probability(d)
    probability_std = math.sqrt(probability * (1.0 - probability) / n)
    return probability, probability_std


def invert_probability_to_pi(probability: float, d: int) -> float:
    if probability < 0.0:
        raise ValueError("probability must be non-negative.")
    prefactor = (2.0**d) * math.gamma(d / 2.0 + 1.0)
    return (prefactor * probability) ** (2.0 / d)


def delta_method_pi_std(probability: float, probability_std: float, d: int) -> float:
    if probability <= 0.0:
        return math.inf
    pi_value = invert_probability_to_pi(probability, d)
    derivative = (2.0 / d) * pi_value / probability
    return abs(derivative) * probability_std


def summarise_result(
    *,
    variant: str,
    hits: int,
    n: int,
    d: int,
    elapsed_s: float,
    num_threads: int,
    mpi_processes: int,
) -> ExperimentResult:
    hit_probability = hits / n
    analytic_probability, analytic_probability_std = analytic_probability_stats(d, n)
    pi_estimate = invert_probability_to_pi(hit_probability, d)
    analytic_pi_std = delta_method_pi_std(
        analytic_probability,
        analytic_probability_std,
        d,
    )
    return ExperimentResult(
        variant=variant,
        hits=hits,
        n=n,
        d=d,
        hit_probability=hit_probability,
        analytic_probability=analytic_probability,
        analytic_probability_std=analytic_probability_std,
        pi_estimate=pi_estimate,
        analytic_pi_std=analytic_pi_std,
        elapsed_s=elapsed_s,
        num_threads=num_threads,
        mpi_processes=mpi_processes,
    )


def build_parser(description: str) -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument(
        "-d",
        "--dimension",
        dest="d",
        type=int,
        default=2,
        help="Dimension of the cube and sphere.",
    )
    parser.add_argument(
        "-n",
        "--num-samples",
        dest="n",
        type=int,
        default=1_048_576,  # 2**20
        help="Number of Monte Carlo samples per thread.",
    )
    parser.add_argument(
        "-t",
        "--num-threads",
        dest="num_threads",
        type=int,
        default=default_num_threads(),
        help="Thread count used by the threaded variants.",
    )
    parser.add_argument(
        "-s",
        "--seed",
        dest="seed",
        type=int,
        default=20260421,
        help="Base random seed.",
    )
    parser.add_argument(
        "-c",
        "--chunk-size",
        dest="chunk_size",
        type=int,
        default=262_144,  # 2**18
        help="Maximum number of points generated per array batch.",
    )
    parser.add_argument(
        "--save",
        dest="save",
        type=str,
        default=None,
        metavar="FILE",
        help="Write 'hits n' to FILE for downstream reduction (map-reduce pattern).",
    )
    return parser


def parse_config(description: str) -> ExperimentConfig:
    args = build_parser(description).parse_args()
    if args.d < 1:
        raise ValueError("d must be a positive integer.")
    if args.n < 1:
        raise ValueError("n must be a positive integer.")
    if args.num_threads < 1:
        raise ValueError("num_threads must be a positive integer.")
    if args.chunk_size < 1:
        raise ValueError("chunk_size must be a positive integer.")
    return ExperimentConfig(
        d=args.d,
        n=args.n * args.num_threads,
        num_threads=args.num_threads,
        seed=args.seed,
        chunk_size=args.chunk_size,
        save=args.save,
    )


def format_results_table(results: list[ExperimentResult]) -> str:
    header = (
        f"{'variant':<16} {'hits':>12} {'p_hat':>10} {'p_true':>10} "
        f"{'sigma_p':>10} {'pi_hat':>10} {'sigma_pi':>10} "
        f"{'thr':>5} {'ranks':>5} {'time[s]':>10}"
    )
    lines = [header, "-" * len(header)]
    for result in results:
        lines.append(
            f"{result.variant:<16} "
            f"{result.hits:>12d} "
            f"{result.hit_probability:>10.6f} "
            f"{result.analytic_probability:>10.6f} "
            f"{result.analytic_probability_std:>10.6f} "
            f"{result.pi_estimate:>10.6f} "
            f"{result.analytic_pi_std:>10.6f} "
            f"{result.num_threads:>5d} "
            f"{result.mpi_processes:>5d} "
            f"{result.elapsed_s:>10.4f}"
        )
    return "\n".join(lines)


def print_results(config: ExperimentConfig, results: list[ExperimentResult]) -> None:
    print(f"d={config.d} N={config.n} num_threads={config.num_threads} seed={config.seed}")
    print(format_results_table(results))


def timed_count(count_hits, config: ExperimentConfig) -> tuple[int, float]:
    start = time.perf_counter()
    hits = count_hits(config)
    elapsed_s = time.perf_counter() - start
    return hits, elapsed_s


def save_raw_result(result: ExperimentResult, path: str) -> None:
    """Write 'hits n' to path so reduce_results.py can combine multiple runs."""
    dest = Path(path)
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(f"{result.hits} {result.n}\n")
