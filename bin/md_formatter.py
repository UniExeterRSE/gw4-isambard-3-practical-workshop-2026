#!/usr/bin/env python3
"""Format markdown files by normalizing through pandoc."""

import argparse
import subprocess
import sys
from pathlib import Path
from typing import Sequence

COMMON_ARGS: list[str] = ["--columns=120"]

FORMAT_ARGS: dict[str, list[str]] = {
    "gfm": ["-t", "gfm"],
    "markdown": ["-t", "markdown"],
}


def pandoc_args_for_format(fmt: str) -> list[str]:
    return [*COMMON_ARGS, *FORMAT_ARGS.get(fmt, ["-t", fmt])]


def format_file(path: Path, fmt_args: list[str]) -> None:
    result = subprocess.run(
        ["pandoc", *fmt_args, str(path)],
        capture_output=True,
        check=True,
    )
    path.write_bytes(result.stdout)


def resolve_paths(glob_pattern: str) -> list[Path]:
    return sorted(Path(".").glob(glob_pattern))


def parse_args(argv: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Format markdown files by normalizing through pandoc.",
    )
    parser.add_argument(
        "pattern",
        help="Glob pattern for files to format, e.g. '**/*.md'",
    )
    parser.add_argument(
        "-t",
        dest="format",
        required=True,
        help="Output format passed to pandoc's -t flag",
    )
    return parser.parse_args(argv)


def main(argv: Sequence[str] = sys.argv[1:]) -> None:
    args = parse_args(argv)
    fmt_args = pandoc_args_for_format(args.format)
    paths = resolve_paths(args.pattern)
    if not paths:
        print(f"No files matched: {args.pattern}", file=sys.stderr)
        sys.exit(1)
    for path in paths:
        print(f"formatting {path}")
        format_file(path, fmt_args)


if __name__ == "__main__":
    main()
