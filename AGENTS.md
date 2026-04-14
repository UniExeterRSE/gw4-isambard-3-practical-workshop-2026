# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

Teaching materials — not an application. It is the content for a 2.5-hour hands-on workshop on the GW4 Isambard 3 HPC
system (Tuesday 21 April 2026). Most files are markdown walkthroughs, example Slurm batch scripts, and a Python
Monte Carlo Pi example used to demonstrate array jobs and parallelism strategies. Treat `README.md` as the workshop
blueprint and source of truth for schedule, section goals, and scope; changes that affect content should be
cross-checked against its "Out of Scope" and per-section TODO lists.

## Tooling: Pixi + direnv

Environment is managed by [Pixi](https://pixi.sh) (conda-forge channel). `.envrc` runs `pixi shell-hook`, so with
direnv enabled the env activates on `cd`. Otherwise use `pixi run <task>` or `pixi shell`.

The root `pyproject.toml` declares both a PEP 621 project (`isambard3-workshop`) and a Pixi workspace. The project is
installed editably into the Pixi env, so Python modules under `src/section_*/` are importable by their
`section_NN_*` package names (e.g. `python -m section_05_python_array_jobs_parallelism_strategies.monte_carlo_pi_numpy`).

## Common commands

All via Pixi tasks (defined in `pyproject.toml` under `[tool.pixi.tasks]`):

- `pixi run format` — run all formatters (depends on `format-sh`, `format-md`, `format-markdown`, `format-py`). CI
  enforces `git diff --exit-code` after this, so always run it before committing.
- `pixi run format-py` — `ruff check --fix` + `ruff format` on `src/` and `bin/`.
- `pixi run format-md` — normalise `*.md` files through pandoc (GFM, 120-column).
- `pixi run format-markdown` — normalise `*.markdown` files through pandoc (plain `markdown`, 120-column).
- `pixi run format-sh` — `sed` + `shfmt` (`bin/sh_formatter.sh`); rewrites `$var` → `${var}` and `[ … ]` → `[[ … ]]`
  in every tracked `*.sh`.
- `pixi run sync` — `jupytext --sync` on paired `*.ipynb` / `*.py` files. Python files use the `py:percent` format.
- `pixi run docs` — build reveal.js HTML slides via `make -C src all` (pandoc → reveal.js from `*.markdown`).
- `pixi run serve` — build then serve `src/` on `http://127.0.0.1:8001`.
- `pixi run monte-carlo-pi-summary` — run the parallel-strategies summary script.

There is no test suite. "Quality" means: formatters are idempotent, docs build, and slide HTML regenerates cleanly.

## File-type conventions (important — they are not interchangeable)

- `*.md` — exercise walkthroughs, READMEs, and attendee-facing prose. Formatted via `pixi run format-md` (GFM).
- `*.markdown` — **slide source only**. Consumed by `src/makefile` and compiled to `*.html` reveal.js decks with
  pandoc args defined in `src/makefile` (1920×1080, UoE theme at `/assets/theme.css`). Formatted via
  `pixi run format-markdown` (plain `markdown`, not GFM — GFM changes syntax that pandoc's reveal.js writer needs).
- `*.sh` — Slurm batch examples and runner scripts. After formatting, all variable references are `${var}` form and
  all test brackets are `[[ … ]]`; do not reintroduce POSIX `[ … ]` or bare `$var`.
- `*.py` under `src/section_*/` — importable modules. Respect the entry points in `[project.scripts]` when
  renaming functions or files.

## Repository layout

- `src/section_NN_<slug>/` — one directory per workshop section. Numbering matches the schedule in `README.md`.
  Each directory is a Python package (`__init__.py`) and contains the section's walkthroughs, example scripts, and its
  own `README.md` with presenter/attendee notes.
- `src/assets/` — shared slide theme (`theme.css`), template (`template.markdown`), images, and a sub-makefile.
- `src/makefile` — top-level slide build. `make all` discovers every `*.markdown` under `src/` and compiles it.
- `bin/` — repo-local tooling (`md_formatter.py`, `sh_formatter.sh`) invoked by Pixi tasks.
- `.github/workflows/` — `quality.yml` runs `pixi run format` and fails if the tree changes; `docs.yml` builds
  slides and deploys `src/` to GitHub Pages for `main`/`dev` pushes (and PRs from branches named `ci` or `docs`).

## Ruff configuration

`line-length = 120`, and the lint rule set is intentionally narrow: `I` (imports), `F401` (unused imports — ignored
in `__init__.py`), `F841`, `F601`, `F602`, `F405`. Do not enable broader rule sets without reason; noisy lint churn
is not wanted in teaching material.

## Scope discipline when editing content

The `README.md` is explicit about what is and is not taught in this workshop. When adding or editing section
material, respect the "Out of Scope" list and the per-section "Do **not**" instructions (e.g. no partition changes
in the beginner Slurm path, no `--mail-type=END`, containers are follow-up only, no JupyterHub, no long detours into
bespoke attendee environments). Prefer updating the blueprint first if a scope change is intentional.
