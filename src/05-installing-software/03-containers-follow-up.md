# Containers: Follow-Up Route

Containers are useful, but they are not part of the core hands-on path for this workshop.

## When to mention them

- when software is hard to install directly
- when you need a more reproducible runtime stack
- when a documented container workflow already exists

## Why they are not taught live here

- they add another layer of tooling
- they can distract from the core beginner workflow
- they are not needed for the main workshop learning goals

## Important adaptation from the original tutorial

The original tutorial includes GPU-oriented examples for Isambard AI. For Isambard 3, any batch script examples should be rewritten as CPU-only jobs and should not use GPU directives such as:

```bash
#SBATCH --gpus=1
```

## Follow-up suggestion

If you want to extend this workshop later, add a separate advanced section with:

- a simple `apptainer exec` example
- a CPU-only batch script
- notes on when containers are preferable to modules or conda
