# Section 7 — Tips, Help, Wrap-Up, Q&A & Feedback

Presenter notes for the final 15-minute closing block (12:15–12:30). This is a passive section — no hands-on exercise.

## Slurm tips

### Useful `sbatch` directives

The full reference is [`man sbatch`](https://slurm.schedmd.com/sbatch.html). Other useful man pages:

- [`man srun`](https://slurm.schedmd.com/srun.html)
- [`man squeue`](https://slurm.schedmd.com/squeue.html)
- [`man scancel`](https://slurm.schedmd.com/scancel.html)
- [`man sacct`](https://slurm.schedmd.com/sacct.html)
- [`man scontrol`](https://slurm.schedmd.com/scontrol.html)
- [`man sacctmgr`](https://slurm.schedmd.com/sacctmgr.html)
- [`man sinfo`](https://slurm.schedmd.com/sinfo.html)

Point participants at these directives to look up on their own:

    --mem
    --mem-per-cpu
    --cpus-per-task
    --ntasks-per-node

### Separate stdout and stderr

``` sh
#SBATCH --error=hello_world.err
```

Note: separating them can also be confusing because you lose the interleaving that shows how the two streams relate. Use
it when you need clean parseable output, but keep them merged (the default) while debugging.

### Check CPU usage of completed jobs

`sacct` is the canonical Slurm post-hoc query. Every job step (each `srun` counts as one) gets its resource usage
recorded. After the job finishes:

``` bash
sacct -j ${SLURM_JOB_ID} --format=JobID,JobName%15,Elapsed,TotalCPU,NCPUS,CPUTime,AveCPU,MaxRSS
```

Key columns:

- `TotalCPU` — user + sys CPU time summed over **every task** in the step (this is what you want).
- `Elapsed` — wall clock.
- `NCPUS` — cores allocated to the step.
- `CPUTime` — `Elapsed × NCPUS`, the “budget” you could have used.

Utilisation = `TotalCPU / CPUTime`. A healthy run should be near 1.0; oversubscription shows up as
`TotalCPU > NCPUS × Elapsed` (threads fighting for cores add up to more CPU-seconds than were allocated).

## Slurm cheatsheet

``` sh
# See partitions and basic limits
sinfo
# More detail on partitions/nodes
sinfo -o "%P %a %D %c %m %G %l %N"
# Show detailed partition config
scontrol show partition
# Show info on a particular node
scontrol show node x3008c0s15b2n0
# Show overall Slurm config
scontrol show config
# Show QOS definitions
sacctmgr show qos
# Show one specific partition QOS
sacctmgr show qos grace_qos      # Isambard 3 Grace example
sacctmgr show qos workq_qos      # Isambard-AI example
sacctmgr show qos macs_qos       # Isambard 3 MACS example
# See any extra QOS/associations you have
sacctmgr show user ${USER} withassoc
# See accounts/projects you can charge jobs to
sacctmgr show assoc user=${USER}
# Inspect current jobs
squeue --me
# Inspect current and past jobs
sacct
```

## File transfer one-liners

`rsync`

## Troubleshooting

### Terminal emulator compatibility

Some terminal emulators (e.g. Ghostty, kitty) set a `$TERM` value that the remote system does not recognise, which can
cause garbled output or errors on SSH login. Override it for the SSH session:

``` sh
TERM=xterm-256color command ssh e6c.3.isambard
```

## Where to look next

- **Isambard 3 documentation:** <https://docs.isambard.ac.uk>
- **Slurm documentation:** <https://slurm.schedmd.com/documentation.html>

## Getting help after the workshop

- UoE RSE support: `isambard-support@exeter.ac.uk`
- BriCS helpdesk (system issues, accounts, allocations): <https://support.isambard.ac.uk/>

## Feedback

We will send a short feedback survey by email after the workshop — please fill it in so we can improve future sessions.
