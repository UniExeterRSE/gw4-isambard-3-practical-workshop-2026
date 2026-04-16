## Installing Software {#installing-software .hero-slide}

::::::::: hero-grid
::::::: hero-left
![](../assets/uoe-logo.png){.hero-uoe alt="University of Exeter logo"}

::: hero-title
Installing Software
:::

::: hero-subtitle
conda/mamba, compilers, Spack,\
and containers --- where to look
:::

::: next-steps-card
[Resources]{.card-title}

- [Modules guide](https://docs.isambard.ac.uk/user-documentation/guides/modules/)
- [Spack guide](https://docs.isambard.ac.uk/user-documentation/guides/spack/)
- [Containers guide](https://docs.isambard.ac.uk/user-documentation/guides/containers/)
:::

::: presenter-line
Section 4 --- 15 min
:::

![](../assets/gw4-logo.png){.hero-gw4 alt="GW4 logo"}
:::::::

::: hero-right
![](../assets/isambard-exterior.jpeg){alt="Isambard 3 exterior"}
:::
:::::::::

::: notes
- 15-minute section: keep moving
- Core message: mamba/conda is the primary route for this workshop; compilers are a stretch
- Do NOT get drawn into bespoke attendee environment debugging here --- redirect to docs/support after the session
- Containers (Podman-HPC / Singularity) are follow-up only; do not teach hands-on
- If VS Code or other editor tooling is raised in Q&A, answer briefly and move on
:::

## Software landscape {#software-landscape .shell-slide}

::: slide-subtitle
Four routes --- pick by what your software needs, not in a fixed order
:::

:::: shell-grid
::: shell-text
  Route                            When to reach for it                                      Today?
  -------------------------------- --------------------------------------------------------- -------------
  **mamba / conda**                Package available on conda-forge or another channel       **Primary**
  **System modules + compilers**   Compile your own code; `PrgEnv-gnu` / `gcc-native`        Stretch
  **Spack**                        Complex compiled projects needing system-specific flags   Follow-up
  **Podman-HPC / Singularity**     Deployment wrapper; use any package manager inside        Follow-up

Modules on Isambard 3 are bare-bones --- almost no research software is available through `module avail`. Their main
value is loading the system compiler (`gcc-native`) when you want to compile your own code.

Containers are **orthogonal** to the others: a container can wrap a conda or Spack environment and gives access to
package managers like `apt` or `nix` that are otherwise unavailable on a shared HPC system.
:::
::::

::: notes
- Do not spend long on this slide; it is orientation, not instruction
- The key correction to make explicitly: "module avail will show almost nothing useful for your research"
- Compilers are the one real use for modules; GCC via PrgEnv-gnu or gcc-native is the taught path (Section 1 notes)
- Containers orthogonal point is important if anyone asks "can I use apt inside a container?" --- yes, that's the point
- Redirect Spack and container questions to follow-up docs
:::

## Modules {#modules .shell-slide}

::: slide-subtitle
Useful mainly for the system compiler --- but good to know the commands
:::

:::: shell-grid
::: shell-text
``` bash
# What is currently loaded?
module list

# Reset to system defaults --- good habit at the top of a job script
module reset

# Browse everything available
module avail

# Search for a specific tool
module avail python
module avail gcc

# Load a module
module load brics/emacs

# Unload one module
module unload brics/emacs
```

Stretch: try `module avail` and search for a tool you already use.
:::
::::

::: notes
- Demo live: run module list, module reset, module avail python (likely shows little or nothing)
- Lean into the emptiness as a teaching moment: "this is why we use mamba"
- The commands are still worth knowing --- attendees will see them in job scripts and documentation
- If someone asks about a specific tool: check module avail together, then move on to conda
:::

## How do you install software on a remote machine? {#how-install-software .shell-slide}

::: slide-subtitle
Quick show of hands
:::

::::: shell-grid
:::: shell-text
Which of these have you used on a remote system?

- Copy and paste commands from a tutorial / Stack Overflow
- `brew` (Homebrew)
- `mise`
- `pip` directly into the system Python
- `conda` or `mamba`
- `pixi`
- `modules`
- `Spack`
- Something else entirely

::: slide-note
There is no wrong answer here --- this tells us where to spend the next few minutes.
:::
::::
:::::

::: notes
- Hands-up slide: read the room
- If most people have used conda/mamba, move quickly through the terminology
- If most people are unfamiliar, slow down on the vocabulary slide
- Key point to land: HPC systems are shared; you cannot install into system paths --- you need user-space tooling
:::

## Why not just `pip install` or `sudo apt`? {#why-not-pip-or-apt .shell-slide}

::: slide-subtitle
Shared systems, supply chain risk, and reproducibility
:::

::::: fit-panels
::: {.fit-panel .good}
[Safer routes]{.fit-title}

- **Conda / mamba** --- isolated named environments; easy to delete and recreate
- **Spack** --- built from source with explicit dependencies and system-tuned flags
- **Podman-HPC / Singularity** --- fully self-contained; portable across systems
:::

::: {.fit-panel .bad}
[Avoid on shared systems]{.fit-title}

- `sudo apt install` / system-level installs (you do not have sudo)
- `pip install` into the base Python (pollutes shared paths, breaks other jobs)
- Scripts piped directly to `bash` from unknown sources (supply chain risk)
- `brew`, `mise`, etc. without understanding what they pull in
:::
:::::

::: slide-note
"Supply chain attack": a malicious package masquerading as a popular one. Use trusted channels (conda-forge, PyPI with
known package names) and pin versions in production.
:::

::: notes
- Keep this brief --- 1--2 minutes
- The "sudo" point lands immediately; the supply chain point is worth one sentence
- Do not lecture; move on to the hands-on route
:::

## Clone the workshop repository {#clone-workshop-repo .shell-slide}

::: slide-subtitle
Get the bootstrap scripts onto Isambard 3
:::

::::: columns
::: {.column width="50%"}
**Option A --- Fork (save your own changes)**

1.  Go to <https://github.com/UniExeterRSE/gw4-isambard-3-practical-workshop-2026> and click **Fork**

2.  Generate an SSH key and load the agent:

    ``` bash
    ssh-keygen -t ssh-ed25519 -C "${ISAMBARD_HOST}"
    . <(ssh-agent -s)
    ssh-add ~/.ssh/id_ed25519
    ```

3.  Install `gh` and authenticate:

    ``` bash
    bash <(curl -L https://raw.githubusercontent.com/UniExeterRSE/gw4-isambard-3-practical-workshop-2026/refs/heads/main/bootstrap/install/gh.sh) install
    gh auth login --git-protocol ssh --web
    ```

4.  In your fork click **Code → SSH → copy**, then clone (replace `UniExeterRSE` with your username):

    ``` bash
    mkdir -p ~/git
    cd ~/git
    git clone git@github.com:UniExeterRSE/gw4-isambard-3-practical-workshop-2026.git
    cd gw4-isambard-3-practical-workshop-2026
    pwd
    ```
:::

::: {.column width="50%"}
**Option B --- Read-only HTTPS clone (simpler, no GitHub account needed)**

``` bash
mkdir -p ~/git
cd ~/git
git clone https://github.com/UniExeterRSE/gw4-isambard-3-practical-workshop-2026.git
cd gw4-isambard-3-practical-workshop-2026
# This is where your workshop repo is
pwd
```
:::
:::::

::: notes
- Most attendees will use Option B; point Option A at anyone who wants to keep their own work
- The curl-pipe-to-bash for gh.sh is from our own repo --- acceptable here
- If someone has no internet, they can use the materials already on the workshop project share
:::

## Install mamba and tools {#install-mamba-tools .shell-slide}

::: slide-subtitle
Run the bootstrap scripts from inside the cloned repo
:::

:::: shell-grid
::: shell-text
All bootstrap scripts are in the `bootstrap/` subdirectory:

``` bash
cd bootstrap

# Install VS Code CLI (skip if already done in pre-workshop setup)
install/code.sh install

# Install miniforge (mamba + conda, using conda-forge by default)
install/mamba.sh install

# Install a curated set of command-line tools into a "system" conda env
# (includes gh, parallel, pandoc, git-delta, ripgrep, and more)
NAME=system install/mamba-env.sh install
```

After `mamba.sh install`, open a new shell (or run `source ~/.bashrc`) so that `mamba` is on your path.

``` bash
# Verify
mamba --version
mamba env list
```
:::
::::

::: notes
- Demo live: run mamba.sh install and show the output
- The `system` env is optional for the workshop; the key install is mamba itself
- If someone already has conda or mamba from a previous session, they can skip mamba.sh
- `source ~/.bashrc` is usually enough; a fresh login always works
:::

## Conda vocabulary in two minutes {#conda-vocabulary .shell-slide}

::: slide-subtitle
Anaconda, conda, mamba, miniforge --- what is what?
:::

::::: fit-panels
::: {.fit-panel .good}
[What we use]{.fit-title}

- **mamba** --- a fast drop-in replacement for `conda` (same commands; written in C++)
- **miniforge** --- a minimal community distribution using **conda-forge** by default (no Anaconda licence issues)
- **conda-forge** --- the open-source package channel; over 25,000 packages
- **named environment** --- an isolated software stack you can activate, deactivate, and delete cleanly
:::

::: {.fit-panel .bad}
[What we avoid]{.fit-title}

- **Anaconda (the distribution)** --- has licence restrictions for institutional use at scale; do not install on a
  shared HPC system
- **base environment** --- never install research packages into base; it is the container that holds mamba itself
- **`pip install` into the active env without care** --- can conflict with conda-managed packages
:::
:::::

::: notes
- The Anaconda licence point is important for institutional users --- one sentence is enough
- "Never touch base" is the single most useful conda habit to teach
- Pixi is a newer Rust-based alternative with better project management; mention briefly if asked
:::

## Create and use an environment {#create-use-environment .shell-slide}

::: slide-subtitle
Hands-on: create a Python environment and activate it
:::

::::: columns
::: {.column width="50%"}
**Create from a prepared file** (used in later sections):

``` bash
# From the workshop repo bootstrap directory
mamba env create -f conda/py314_linux-aarch64.yml -y
mamba activate py314
which python
python --version
```

**Or build your own minimal environment**:

``` bash
mamba create -n my_env python=3.14 numpy numba -y
mamba activate my_env
python -c "import numpy; print(numpy.__version__)"
```
:::

::: {.column width="50%"}
**Useful environment commands**:

``` bash
mamba env list               # list all environments
mamba list                   # packages in the active env
mamba deactivate             # return to base
mamba env remove -n my_env   # delete an environment
```

Stretch: use `mamba search <name>` to check whether a package you need is on conda-forge.
:::
:::::

::: slide-note
Environments live under `~/.miniforge3/envs/`. They can be large --- check `$HOME` quota with `lfs quota` if space runs
low.
:::

::: notes
- py314 is the full workshop environment used in later sections; creation takes several minutes --- start it and move on
- Stretch: ask attendees to find a package they use with `mamba search <name>` and add it to a test env
- If creation stalls or fails, fall back to whatever Python module is available from `module avail python`
:::

## Pixi and direnv {#pixi-direnv .shell-slide}

::: slide-subtitle
A newer approach: project-scoped environments
:::

:::: shell-grid
::: shell-text
[Pixi](https://pixi.sh) is a newer Rust-based package manager from the conda-forge ecosystem. It manages environments
per project rather than globally.

``` bash
# If pixi is installed (it is in the "system" conda env):
cd gw4-isambard-3-practical-workshop-2026
pixi shell            # activate this project's environment
pixi run format       # run a task defined in pyproject.toml
```

[direnv](https://direnv.net) pairs with pixi (or any tool) to activate an environment automatically on `cd`:

``` bash
# The project .envrc runs: eval "$(pixi shell-hook)"
# After direnv allow, the env is live whenever you enter the directory
direnv allow
```

This workshop repo uses pixi + direnv internally. You do not need to understand it for today's exercises.
:::
::::

::: notes
- This slide is context for the workshop repo itself, not a teaching requirement
- If no one asks, move quickly through it --- 30 seconds is enough
- Pixi is in the "system" conda env installed via bootstrap; attendees who did that step already have it
:::

## Other routes {#other-routes .shell-slide}

::: slide-subtitle
Beyond modules and conda --- where to look next
:::

:::: shell-grid
::: shell-text
**Spack** --- for compiled software with fine-grained control over flags and dependencies:

<https://docs.isambard.ac.uk/user-documentation/guides/spack/>

**Containers (Podman-HPC / Singularity)** --- for fully self-contained, portable stacks; can wrap any package manager
inside:

<https://docs.isambard.ac.uk/user-documentation/guides/containers/>

**Intro tour (official tutorials)** --- more worked examples on the BriCS docs site:

<https://docs.isambard.ac.uk/user-documentation/tutorials/intro-tour/>

If your own software stack does not fit conda, do not spend workshop time on it. **Ask a helper to note it down and we
will follow up after the session.**
:::
::::

::: notes
- One slide; do not teach Spack or containers in depth
- The key takeaway: these routes exist, they are documented, and the helpers can follow up
- Redirect any bespoke environment discussions explicitly --- "let us note that down and come back to you"
:::

## Discussion {#section-4-discussion .qa-slide}

::: qa-mark
Discussion
:::

::: qa-subtitle
Questions? Anything that did not work, or a tool you use that we have not mentioned?
:::
