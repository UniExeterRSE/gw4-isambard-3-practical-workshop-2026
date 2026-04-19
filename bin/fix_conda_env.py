#!/usr/bin/env python3
"""Post-process a pixi-exported conda environment.yml.

Removes pip entries that duplicate conda-managed packages, keeping only the
editable local install (-e .). If the pip list becomes empty after pruning the
pip: key itself is also removed.
"""

import pathlib
import sys


def fix(path: pathlib.Path) -> None:
    lines = path.read_text().splitlines(keepends=True)
    result: list[str] = []
    in_pip = False
    pip_header_idx: int | None = None

    for line in lines:
        stripped = line.strip()
        if stripped == "- pip:":
            in_pip = True
            pip_header_idx = len(result)
            result.append(line)
        elif in_pip:
            if stripped.startswith("- "):
                if stripped.startswith("- -e "):
                    result.append(line)
                # else: duplicate — drop it
            else:
                in_pip = False
                # If nothing was kept under pip: (no -e entry), remove the header too
                if pip_header_idx is not None and result[-1].strip() == "- pip:":
                    result.pop()
                pip_header_idx = None
                result.append(line)
        else:
            result.append(line)

    path.write_text("".join(result))


if __name__ == "__main__":
    target = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path("environment.yml")
    fix(target)
