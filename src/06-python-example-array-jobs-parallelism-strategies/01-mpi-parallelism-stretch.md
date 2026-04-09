# Stretch Goal: Multi-Node MPI Parallelism

If you need your application to scale beyond the cores available on a single Grace CPU node, you will likely encounter MPI (Message Passing Interface). 

In this exercise, we will measure the bandwidth of the interconnect network between two compute nodes using the OSU Micro-Benchmarks.

## Finding the software

First, load the pre-built `osu-micro-benchmarks` module. Notice that loading this automatically brings in an MPI provider dependency (e.g., `openmpi` or `cray-mpich`).

```bash
module reset
module load brics/osu-micro-benchmarks
```

We can quickly verify the software is available by running the simplest test natively on the login node (it will run with just 1 process):

```bash
osu_hello
```

If successful, the output will look something like:
```text
# OSU MPI Hello World Test v...
This is a test with 1 processes
```

## Running the multi-node job

See `mpi_osu.slurm` for the script. Note the directives that specifically request more than one node:

```bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
```

Submit the script:

```bash
sbatch mpi_osu.slurm
```

Check its status:

```bash
squeue --me
```

## Review the output

Once the job is completed or running, inspect the output:

```bash
cat test_osu.out
```

Since the job uses `srun osu_bw`, the output will show the measured bandwidth (in MB/s) for various message sizes exchanged between the two nodes.

## Key Takeaway

Multi-node parallelism demands "MPI-aware" code. Unlike simple job arrays which dispatch identical independent tasks, MPI allows multiple processes on isolated nodes to communicate back and forth seamlessly during execution.
