# Isambard 3 in One Picture

This workshop is about getting comfortable with the basic workflow on **Isambard 3**:

1. log in
2. find the right storage area
3. submit work with Slurm
4. use modules or a user-managed environment for software

## What Isambard 3 Is

- A BriCS supercomputer for research computing
- A system scheduled with **Slurm**
- A platform based on **Arm/aarch64**
- A **CPU-only** system

## What Isambard 3 Is Not

- It is not the GPU-focused Isambard AI service
- It is not a place to do long interactive development on login nodes
- It is not archival storage

## Working Areas You Will Use

- `$HOME` for shell setup, small scripts, and personal configuration
- `$PROJECTDIR` for shared project material
- `$SCRATCHDIR` for temporary working data and job outputs that do not need to live forever

## Workflow to Emphasise

- Log in on the login node
- Prepare files there
- Submit work to compute nodes with Slurm
- Check output and errors
- Iterate

## Presenter Notes

- Keep architecture detail short
- Say "Arm/aarch64" once or twice, then move on
- Emphasise that the workshop examples are all CPU examples
- Avoid deep discussion of compilers, MPI internals, or custom software stacks here
