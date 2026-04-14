# Python via Conda or Mamba

This exercise shows how to build a small, isolated Python environment instead of installing packages into `base`.

## Why not use `base`?

- It gets cluttered quickly
- Different projects often need different package versions
- Isolated environments are easier to debug and remove

## Create an environment from the YAML file

Use the `environment.yml` file in this directory.

Example pattern:

``` bash
conda env create -f environment.yml
conda activate isambard3-tutorial
python check_scipy.py
```

If the site provides `mamba`, the same workflow is often faster:

``` bash
mamba env create -f environment.yml
conda activate isambard3-tutorial
python check_scipy.py
```

## Run the same check as a batch job

``` bash
sbatch run_python_env_check.sh
cat python_env_check.out
```

## Modules persist; conda environments do not

This is an important difference to understand before submitting batch jobs.

When you load a module on the login node and then launch work via `sbatch` or `srun`, the loaded modules carry over to
the compute node automatically.

Conda environments do **not** behave this way. A `conda activate` in your shell does not survive the transition to a
compute node. You must activate the environment explicitly inside the batch script, which is why
`run_python_env_check.sh` sources the conda initialisation script and calls `conda activate` before running Python.

## Questions

1.  Why is an isolated environment safer than installing into `base`?
2.  What changed between the interactive run and the batch run?
3.  Which parts of the setup belong in the batch script?
4.  What would happen if you removed the `conda activate` line from the batch script?

## Workshop note

If attendees have unusual package requirements, do not debug custom stacks live in the room. Point them to follow-up
support after the session.
