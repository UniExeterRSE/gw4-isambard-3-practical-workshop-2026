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
