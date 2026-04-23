## Isambard 3 Practical Workshop {#isambard-3-practical-workshop .hero-slide}

:::::::::: hero-grid
:::::::: hero-left
![](../assets/uoe-logo.png){.hero-uoe alt="University of Exeter logo"}

::: hero-title
Isambard 3 Practical Workshop
:::

::: hero-subtitle
Hands-on introduction to Tier-2 CPU\
supercomputing on Isambard 3
:::

::: next-steps-card
[Workshop resources]{.card-title}

- [Docs](https://docs.isambard.ac.uk)
- Help: `isambard-support@exeter.ac.uk`
:::

::: docs-qr-block
![[Workshop
site](https://uniexeterrse.github.io/gw4-isambard-3-practical-workshop/)](../assets/workshop-qr.png){alt="Workshop QR code"}
:::

::: presenter-line
Presenter name - Team/Unit - Date
:::

![](../assets/gw4-logo.png){.hero-gw4 alt="GW4 logo"}
::::::::

::: hero-right
![](../assets/isambard-exterior.jpeg){alt="Isambard 3 exterior"}
:::
::::::::::

::: notes
- Keep architecture detail short --- say "Arm/aarch64" once or twice, then move on
- Emphasise that the workshop examples are all CPU examples
- Avoid deep discussion of compilers, MPI internals, or custom software stacks here
- Use the spec table as the "one slide" anchor; do not dwell on internals
- Point out the fit-check table but do not over-explain --- let it speak for itself
- Mention ARM compatibility briefly to reassure, not to teach porting
:::

## What this workshop covers {#what-this-workshop-covers .shell-slide}

::: slide-subtitle
Getting comfortable with the basic Isambard 3 workflow
:::

:::: shell-grid
::: shell-text
This workshop is about getting comfortable with the basic workflow on **Isambard 3**: log in, find the right storage
area, submit work with Slurm, and use modules or a user-managed environment for software.

By the end of the session you will have submitted real jobs, run Python on the system, and debugged common failures ---
everything you need to start using Isambard 3 for your own research.

Today: system overview → first commands → batch jobs → software setup → parallelism → debugging.
:::
::::

## Isambard 3 in one slide {#isambard-3-in-one-slide .shell-slide}

::::: shell-grid
::: shell-text
Operated by the GW4 partnership; hosted by the University of Bristol.

384 nodes based on NVIDIA Grace CPU Superchips (ARM aarch64).

Per node: 144 CPU cores, 240 GB memory, 200 Gbps Slingshot 11 network.

Self-service software model: build your own stack (Spack / Conda / containers).

  Detail            Value
  ----------------- -------------------------------------------------
  Nodes             384
  CPU               NVIDIA Grace CPU Superchip (**Arm/aarch64**)
  Cores per node    144
  Memory per node   240 GB
  Interconnect      200 Gbps Slingshot 11
  Scheduler         **Slurm**
  Software model    Self-service: modules, Spack, Conda, containers
:::

::: grid-image
![](../assets/isambard-exterior.jpeg){alt="Isambard 3 exterior"}
:::
:::::

## What Isambard 3 is (and is not) {#what-isambard-3-is-and-is-not .shell-slide}

::::: fit-panels
::: {.fit-panel .good}
[What it is]{.fit-title}

- A BriCS supercomputer for research computing
- A system scheduled with **Slurm**
- A platform based on **Arm/aarch64** --- not x86_64
- A **CPU-only** system
:::

::: {.fit-panel .bad}
[What it is not]{.fit-title}

- It is **not** the GPU-focused Isambard AI service
- It is **not** a place to do long interactive development on login nodes
- It is **not** archival storage
:::
:::::

## Fit check: suitable vs unsuitable workloads {#fit-check-suitable-vs-unsuitable-workloads .shell-slide}

::::: fit-panels
::: {.fit-panel .good}
[Suitable]{.fit-title}

- Parallel workloads that can use many of the 144 cores on a node
- Memory-intensive jobs (up to 240 GB per node)
- Serial or smaller jobs --- billed proportionally by fraction of node used
- ARM-ready code and libraries (aarch64)
:::

::: {.fit-panel .bad}
[Usually not suitable]{.fit-title}

- Workflows requiring GPUs
- x86_64-only software that can't be ported to ARM
- Conda or containers with dependencies lacking aarch64 support
:::
:::::

::: slide-note
If unsure whether your workload fits, talk to us after the session or email `isambard-support@exeter.ac.uk`.
:::

## ARM compatibility in practice {#arm-compatibility-in-practice .shell-slide}

::: slide-subtitle
It's usually easier than you think
:::

::::: shell-grid
::: shell-text
**Languages:** Python, R, C, C++, Fortran, Julia, and Java all run natively on ARM.

**Package managers:** conda-forge and pip have extensive aarch64 builds. Spack builds from source and supports ARM out
of the box.

**Containers:** Multi-arch Docker/Apptainer images work directly. You can also build ARM-native containers on the
system.

**Common HPC libraries:** MPI (OpenMPI, MPICH), OpenBLAS, FFTW, HDF5, NetCDF, and PETSc all build cleanly on aarch64.

**What might not work:** Pre-compiled x86_64-only binaries, or niche libraries without ARM support. If unsure, ask us
--- we can do a quick check.
:::

::: grid-image
![](../assets/machine-room.jpeg){alt="Isambard machine room"}
:::
:::::

## Working areas you will use {#working-areas-you-will-use .shell-slide}

:::: shell-grid
::: shell-text
  Variable        Purpose                                              Notes
  --------------- ---------------------------------------------------- ----------------------------------------------------
  `$HOME`         Shell setup, small scripts, personal configuration   Limited quota --- do not store large datasets here
  `$PROJECTDIR`   Shared project material                              Visible to project collaborators
  `$SCRATCHDIR`   Temporary working data and job outputs               **Not permanent** --- files may be purged

Before running anything expensive, ask yourself: does this belong in home, project, or scratch?
:::
::::

## Workshop workflow {#workshop-workflow .shell-slide}

:::: shell-grid
::: shell-text
Everything in this workshop follows the same loop:

1.  Log in on the login node
2.  Prepare files there
3.  Submit work to compute nodes with Slurm
4.  Check output and errors
5.  Iterate
:::
::::

## Getting help {#getting-help .shell-slide}

::::: contact-grid
::: contact-card
Workshop helpers are circulating --- raise a hand any time.

After the workshop: `isambard-support@exeter.ac.uk`

Docs: <https://docs.isambard.ac.uk>
:::

::: cta-card
![Isambard 3 documentation](../assets/docs-qr.png){alt="Docs QR code"}
:::
:::::
