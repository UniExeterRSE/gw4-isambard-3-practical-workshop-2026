# A 4-Node Job With Slower-Than-Expected Timing

A 4-node MPI+OpenMP job runs to completion without errors, but the wall-clock time is worse than you’d expect for the
chosen configuration.

**Prerequisite:** a 4-node job allocation and the `monte_carlo_pi_mpi_hybrid` binary compiled from
`src/section_05_python_array_jobs_parallelism_strategies/ex02_monte_carlo_pi_c/`.

------------------------------------------------------------------------------------------------------------------------

## Submit it

``` bash
cd src/section_06_debugging_failed_jobs/ex06_mpi_topology
sbatch sbatch_mpi_topology.sh
```

## Monitor it

``` bash
squeue --me
```

Once finished, inspect the output:

``` bash
cat mpi_topology_<JOBID>.out
```

------------------------------------------------------------------------------------------------------------------------

## What do you see?

- Look at the `hostname` lines at the top of the output (printed before the main `srun`). How many ranks appear on each
  node?
- Look at the wall time. Does it match your expectations for the (ranks × threads) configuration?

------------------------------------------------------------------------------------------------------------------------

## Investigate

- Is the rank-per-node distribution even? How many ranks per node would be ideal for 4 nodes?
- For each node that has 2 ranks: how many threads are running on that node in total? How does that compare to 144 (the
  core count per node)?
- For each node that has 1 rank: how many of its 144 cores are actually being used?
- Which node’s wall time dominates the overall job time — the busiest node or the least busy?

------------------------------------------------------------------------------------------------------------------------

## Hints

> Try to debug it yourself first. Come back here if you’re stuck.

- Is 6 divisible by 4 (the node count)? What does Slurm do when ranks can’t be split evenly across nodes?
- Look at the comments in
  `src/section_05_python_array_jobs_parallelism_strategies/ex02_monte_carlo_pi_c/sbatch_monte_carlo_pi_mpi_hybrid_c_multinode.sh`
  — what two constraints does it state about the `NPROCS_LIST` entries?
- The `srun` flag `--ntasks-per-node` forces a specific number of ranks per node. How would you use it here to make the
  distribution explicit? (Careful: does that actually solve the underlying problem with 6 ranks on 4 nodes?)
- What values of `--ntasks` are both multiples of 4 and exact divisors of 576? Which of those is closest to 6?
