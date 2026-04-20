## Tips, Help & Wrap-Up {#tips-help-wrap-up .hero-slide}

::::::::: hero-grid
::::::: hero-left
![](../assets/uoe-logo.png){.hero-uoe alt="University of Exeter logo"}

::: hero-title
Tips, Help & Wrap-Up
:::

::: hero-subtitle
Slurm cheatsheet, troubleshooting,\
and where to go from here
:::

::: next-steps-card
[Resources]{.card-title}

- [Docs](https://docs.isambard.ac.uk)
- [Slurm docs](https://slurm.schedmd.com/documentation.html)
- Help: `isambard-support@exeter.ac.uk`
:::

::: presenter-line
Section 7 --- 15 min
:::

![](../assets/gw4-logo.png){.hero-gw4 alt="GW4 logo"}
:::::::

::: hero-right
![](../assets/isambard-exterior.jpeg){alt="Isambard 3 exterior"}
:::
:::::::::

::: notes
- Final 15-minute passive block --- no hands-on exercise
- Keep pace brisk; these are reference slides attendees can revisit later
- Leave at least 5 minutes for Q&A at the end
:::

## Useful sbatch directives {#useful-sbatch-directives .shell-slide}

::: slide-subtitle
Directives to explore on your own --- `man sbatch` is the full reference
:::

:::: shell-grid
::: shell-text
  Directive             Purpose
  --------------------- -------------------------------
  `--mem`               Total memory for the job
  `--mem-per-cpu`       Memory per allocated CPU core
  `--cpus-per-task`     CPU cores per task (threads)
  `--ntasks-per-node`   Number of tasks on each node

Other useful man pages:

`man srun` · `man squeue` · `man scancel` · `man sacct` · `man scontrol` · `man sacctmgr` · `man sinfo`

All are also available online at <https://slurm.schedmd.com>.
:::
::::

::: notes
- Do not teach these directives in detail --- point attendees at the man pages
- The goal is awareness: "these exist and are worth reading when you need them"
:::

## Separate stdout and stderr {#separate-stdout-stderr .shell-slide}

::: slide-subtitle
Useful for clean parseable output --- but keep them merged while debugging
:::

:::: shell-grid
::: shell-text
``` bash
#SBATCH --output=hello_world.out
#SBATCH --error=hello_world.err
```

By default Slurm merges both streams into `--output`. Splitting them gives you clean output you can parse or
post-process.

**Trade-off:** you lose the interleaving that shows how stdout and stderr relate in time. Keep them merged while
debugging, split them when you need machine-readable output.
:::
::::

## Check CPU usage of completed jobs {#check-cpu-usage .shell-slide}

::: slide-subtitle
sacct tells you how efficiently your job used its allocation
:::

:::: shell-grid
::: shell-text
``` bash
sacct -j ${SLURM_JOB_ID} \
  --format=JobID,JobName%15,Elapsed,TotalCPU,NCPUS,CPUTime,AveCPU,MaxRSS
```

  Column       Meaning
  ------------ ------------------------------------------------------
  `TotalCPU`   User + sys CPU time summed over all tasks
  `Elapsed`    Wall-clock time
  `NCPUS`      Cores allocated
  `CPUTime`    `Elapsed × NCPUS` --- the budget you could have used
  `MaxRSS`     Peak memory usage

**Utilisation** = `TotalCPU / CPUTime`. A healthy run is near 1.0.

If `TotalCPU > NCPUS × Elapsed`, threads are fighting for cores --- you have allocated fewer cores than the job actually
uses.
:::
::::

::: notes
- Every srun step gets its own row in sacct output
- Encourage attendees to run this on their earlier jobs to see real numbers
:::

## Slurm cheatsheet {#slurm-cheatsheet .shell-slide}

::: slide-subtitle
Commands worth bookmarking --- reference, not memorisation
:::

::::: columns
::: {.column width="50%"}
``` bash
# Partitions and limits
sinfo
sinfo -o "%P %a %D %c %m %G %l %N"
scontrol show partition

# Node details
scontrol show node x3008c0s15b2n0

# Overall config
scontrol show config
```
:::

::: {.column width="50%"}
``` bash
# QOS and accounting
sacctmgr show qos
sacctmgr show qos grace_qos
sacctmgr show user ${USER} withassoc
sacctmgr show assoc user=${USER}

# Your jobs
squeue --me
sacct
```
:::
:::::

::: notes
- These are all read-only queries --- safe to run on the login node
- `sacctmgr show assoc` is the one to remember when you need to find your account/project name for `--account`
:::

## File transfer {#file-transfer .shell-slide}

::: slide-subtitle
rsync is the universal workhorse
:::

:::: shell-grid
::: shell-text
``` bash
# Push a directory to Isambard
rsync -avz my_project/ e6c.3.isambard:${PROJECTDIR}/my_project/

# Pull results back
rsync -avz e6c.3.isambard:${SCRATCHDIR}/results/ ./results/
```

- `-a` archive mode (preserves permissions, timestamps, symlinks)
- `-v` verbose
- `-z` compress during transfer

`rsync` only transfers changed files on subsequent runs --- safe to re-run after interrupted transfers.
:::
::::

## Troubleshooting: terminal compatibility {#troubleshooting-terminal .shell-slide}

::: slide-subtitle
Garbled output on SSH? Your terminal might be setting an unknown `$TERM`
:::

:::: shell-grid
::: shell-text
Some terminal emulators (e.g. Ghostty, kitty) set a `$TERM` value the remote system does not recognise.

**Fix:** override `$TERM` for the SSH session:

``` bash
TERM=xterm-256color command ssh e6c.3.isambard
```

Or add to your SSH config:

``` bash
Host e6c.3.isambard
    SetEnv TERM=xterm-256color
```
:::
::::

## Where to look next {#where-to-look-next .shell-slide}

:::::: flow-row
::: flow-card
[Isambard 3 docs]{.flow-title}

<https://docs.isambard.ac.uk>

System guides, storage, Slurm, software, containers.
:::

::: flow-card
[Slurm docs]{.flow-title}

<https://slurm.schedmd.com/documentation.html>

Full reference for every command and directive.
:::

::: flow-card
[BriCS helpdesk]{.flow-title}

<https://support.isambard.ac.uk/>

System issues, accounts, allocations.
:::
::::::

## Getting help {#getting-help .shell-slide}

::::: contact-grid
::: contact-card
**UoE RSE support** (workshop follow-up, usage questions):

`isambard-support@exeter.ac.uk`

**BriCS helpdesk** (system issues, accounts, allocations):

<https://support.isambard.ac.uk/>
:::

::: cta-card
![Isambard 3 documentation](../assets/docs-qr.png){alt="Docs QR code"}
:::
:::::

## Questions? {#questions .qa-slide}

::: qa-mark
Q & A
:::

::: qa-subtitle
Questions, comments, or things you want to try next?
:::

## Feedback {#feedback .shell-slide}

:::: shell-grid
::: shell-text
We will send a short feedback survey by email after the workshop.

**Please fill it in** --- your responses directly shape future sessions.

Thank you for attending!
:::
::::
