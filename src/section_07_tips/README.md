# Drafts

## Slurm

more on sbatch directives, run `man sbatch` or go to https://slurm.schedmd.com/sbatch.html

E.g. look up that these means

    --mem
    --mem-per-cpu
    --cpus-per-task
    --ntasks-per-node 

TODO: add more pages

### Tips

``` sh
#SBATCH --error=hello_world.err
```

#### Get CPU usage of `srun` tasks

`sacct` — the canonical Slurm post-hoc query.** Every job step (each `srun` counts as one) gets its resource usage recorded. After the job finishes:

```bash
sacct -j ${SLURM_JOB_ID} --format=JobID,JobName%15,Elapsed,TotalCPU,NCPUS,CPUTime,AveCPU,MaxRSS
```

Key columns:

- `TotalCPU` = user + sys CPU time summed over **every task** in the step (this is what you want).
- `Elapsed` = wall clock.
- `NCPUS` = cores allocated to the step.
- `CPUTime` = `Elapsed × NCPUS` — the "budget" you could have used.

Utilisation = `TotalCPU / CPUTime`. A healthy hybrid run should be near 1.0; oversubscription shows up as `TotalCPU > NCPUS × Elapsed` (threads fighting for cores add up to more CPU-seconds than were allocated).

### Cheatsheet

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
sacctmgr show user $USER withassoc
# See accounts/projects you can charge jobs to
sacctmgr show assoc user=$USER
# Inspect current jobs
squeue --me
# Inspect current and past jobs
sacct
```
