# Exercise 6 — MPI Topology: Uneven Rank Distribution Across Nodes

**Prerequisite:** a 4-node job allocation and the `monte_carlo_pi_mpi_hybrid` binary compiled from
`src/section_05_python_array_jobs_parallelism_strategies/ex02_monte_carlo_pi_c/`.

------------------------------------------------------------------------------------------------------------------------

## The scenario

You are running a 4-node job on Isambard 3 Grace (144 cores per node, 576 cores total). You want a hybrid MPI + OpenMP
run and decide on **6 MPI ranks × 96 OpenMP threads** per rank:

    6 ranks × 96 threads = 576 workers = 4 × 144

The arithmetic looks right — you are using every available core. But something is wrong with how Slurm distributes the
ranks across the four nodes.

------------------------------------------------------------------------------------------------------------------------

## Submit the job

``` bash
cd src/section_06_debugging_failed_jobs/ex06_mpi_topology
sbatch sbatch_mpi_topology.sh
```

Monitor with:

``` bash
squeue --me
```

Once finished, inspect the output:

``` bash
cat mpi_topology_<JOBID>.out
```

------------------------------------------------------------------------------------------------------------------------

## What do you see?

### Rank → node mapping

The first section of the output shows the hostname reported by each of the 6 ranks. Look for repeated hostnames:

    === Rank → node mapping ===
    node-0001
    node-0001
    node-0002
    node-0002
    node-0003
    node-0004

Two nodes appear **twice** and two nodes appear **once**. Slurm used a round-robin assignment and 6 does not divide
evenly by 4, so the distribution is uneven.

### Timing

The wall time for this configuration is likely **worse** than a comparable run with `nproc=4` or `nproc=8` from Section
5 Exercise 2, even though those also use 576 total workers. The reason is resource contention on the oversubscribed
nodes.

------------------------------------------------------------------------------------------------------------------------

## Topology analysis

    4 nodes available, 6 ranks requested

    Slurm distributes (round-robin, no --ntasks-per-node):
      Node A: 2 ranks × 96 threads = 192 threads on 144 cores  → OVERSUBSCRIPTION
      Node B: 2 ranks × 96 threads = 192 threads on 144 cores  → OVERSUBSCRIPTION
      Node C: 1 rank × 96 threads  =  96 threads on 144 cores  → 48 cores idle
      Node D: 1 rank × 96 threads  =  96 threads on 144 cores  → 48 cores idle

    Wall time = max(node A, node B, node C, node D)
              = dominated by nodes A and B (oversubscribed)

Nodes A and B have 192 threads competing for 144 physical cores. The OS scheduler time-slices those threads, increasing
memory-bandwidth pressure and adding context-switching overhead. Nodes C and D finish faster but must wait — 48 cores
per node sit completely idle throughout the run.

------------------------------------------------------------------------------------------------------------------------

## Questions

1.  Is 6 a multiple of 4? What constraint must the number of ranks satisfy so that every node receives exactly the same
    number of ranks?

2.  Look at the `hostname` output from the diagnostic `srun`. How many distinct node names appear, and how many ranks
    landed on each? Does this match the topology analysis above?

3.  Why does oversubscription on nodes A and B hurt the **overall** wall time even though nodes C and D finish early?

4.  What would happen if you added `--ntasks-per-node=2` to the `srun` call? Would that fix the oversubscription, and
    would any cores still be wasted?

------------------------------------------------------------------------------------------------------------------------

## How to fix it

### Option 1 — choose an evenly divisible rank count

Pick an `nproc` that is both an **exact divisor of 576** and a **multiple of 4** (number of nodes):

    Valid choices: 4, 8, 12, 16, 24, 36, 48, 72, 96, 144, 192, 288, 576

For example, `nproc=4` gives 1 rank per node × 144 threads — pure threading, no oversubscription.

### Option 2 — force even distribution with `--ntasks-per-node`

If you want to keep `nproc=6` you can pin `--ntasks-per-node` explicitly:

``` bash
# 6 ranks across 4 nodes cannot be made even — use a valid count instead.
# With --ntasks-per-node you at least make the intent explicit and Slurm
# will error rather than silently oversubscribe.
srun -n 8 --ntasks-per-node=2 --cpus-per-task=72 --cpu_bind=cores \
    monte_carlo_pi_mpi_hybrid -d 2 -n "${N}"
```

### The correct multinode script

The sweep script at
`src/section_05_python_array_jobs_parallelism_strategies/ex02_monte_carlo_pi_c/sbatch_monte_carlo_pi_mpi_hybrid_c_multinode.sh`
shows both constraints applied together:

``` bash
NPROCS_LIST=(4 8 12 16 24 32 36 48 72 96 144 192 288 576)

for nproc in "${NPROCS_LIST[@]}"; do
    nthreads=$((TOTAL_WORKERS / nproc))
    ntasks_per_node=$((nproc / 4))          # always a whole number
    srun -n "${nproc}" --ntasks-per-node="${ntasks_per_node}" \
        --cpus-per-task="${nthreads}" --cpu_bind=cores \
        monte_carlo_pi_mpi_hybrid -d 2 -n "${N}"
done
```

Every entry in `NPROCS_LIST` divides 576 exactly **and** is a multiple of 4, so `ntasks_per_node` is always a whole
number and no node is ever oversubscribed.
