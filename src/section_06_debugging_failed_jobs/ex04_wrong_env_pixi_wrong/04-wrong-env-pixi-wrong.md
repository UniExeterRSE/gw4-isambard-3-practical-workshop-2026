# MPI Fails Despite Pixi Being Loaded

The pixi environment activates and Python imports succeed. But the job fails when MPI is used — a library error stops
the run.

## Submit it

``` bash
sbatch sbatch_wrong_env_pixi_wrong.sh
```

## Monitor it

``` bash
squeue --me
```

Once the job ends, read the output:

``` bash
cat wrong_env_pixi_wrong_<jobid>.out
```

## What do you see?

Read the error message carefully.

- Does the error mention a library, a symbol, or a version mismatch?
- Does the crash happen at import time, at MPI initialisation, or later?
- Python started successfully. What does that tell you about which part of the environment is broken?

## Investigate

1.  This script loads *a* pixi environment — is it the right one for this system?
2.  Both the `default` and `hpc` pixi environments include `mpi4py`. Are they configured identically?
3.  What MPI implementation does the Cray system provide at runtime, and how does it reach your Python process?
4.  The Cray system injects its own MPI library at runtime. What would happen if the `mpi4py` inside your pixi
    environment was not built to be compatible with it?

## Hints

> Try to debug it yourself first. Come back here if you’re stuck.

- Look at `[tool.pixi.feature.hpc]` in `pyproject.toml`. What package is listed there that is not in the default
  environment?
- What does a build string of `external_*` mean for an `mpich` entry? (See the Pixi or conda-forge documentation.)
- The MPI batch scripts in `src/section_05_python_array_jobs_parallelism_strategies/ex01_monte_carlo_pi/` invoke pixi
  with an explicit flag. What flag is that, and why does it matter here?
