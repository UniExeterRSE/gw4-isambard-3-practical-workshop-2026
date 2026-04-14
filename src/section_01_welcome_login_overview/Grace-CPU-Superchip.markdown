## NVIDIA Grace CPU Superchip {#nvidia-grace-cpu-superchip .hero-slide}

:::::::: hero-grid
:::::: hero-left
![University of Exeter logo](/assets/uoe-logo.png){.hero-uoe}

::: hero-title
NVIDIA Grace CPU Superchip
:::

::: hero-subtitle
The hardware powering every Isambard 3 node
:::

::: presenter-line
GW4 Isambard 3 Practical Workshop --- 21 April 2026
:::

![GW4 logo](/assets/gw4-logo.png){.hero-gw4}
::::::

::: hero-right
![The NVIDIA Grace CPU Superchip module, with two Grace CPUs co-packaged on a single
board](/media/NVidia/Grace-CPU-Superchip/image-001-000.jpg)
:::
::::::::

::: notes
- Deep-dive into the hardware; the system-overview slides covered the top-line specs already
- Focus on what matters for job planning: NUMA nodes, memory bandwidth, vectorization
- Aim for roughly 5--8 minutes across these slides; use them as anchors for discussion, not a lecture
- Attendees come from varied backgrounds --- briefly explain NUMA if the group looks uncertain
:::

## Two Grace CPUs in one module {#two-grace-cpus .shell-slide}

::: slide-subtitle
What "Superchip" means
:::

::::: shell-grid
::: shell-text
A **Grace CPU Superchip** packages two **NVIDIA Grace CPUs** on a single compact module.

### Cores

- **144 Arm Neoverse V2 cores** across the Superchip
- **72 cores per Grace CPU**

### The interconnect

- The two CPUs are linked by **NVLink-C2C (Chip-to-Chip)**
- **900 GB/s bidirectional bandwidth** between them --- far faster than PCIe

This tight coupling is why the Superchip behaves more like a single processor than a conventional dual-socket server.
:::

::: grid-image
![A closer view of the two Grace CPU dies and surrounding LPDDR5X memory
packages](/media/NVidia/Grace-CPU-Superchip/image-005-002.jpg)
:::
:::::

::: notes
- "NVLink-C2C" is NVIDIA's proprietary chip-to-chip interconnect, unrelated to GPU NVLink
- 900 GB/s bidirectional is orders of magnitude faster than PCIe 5.0 x16 (\~128 GB/s)
- Key takeaway: cross-NUMA access on Grace is much cheaper than on a typical dual-socket x86 server
:::

## NUMA topology: simpler than a conventional server {#numa-topology .shell-slide}

::: slide-subtitle
Two NUMA nodes, one Superchip
:::

::::: shell-grid
::: shell-text
Within each Grace CPU, cores, cache, memory, and I/O are connected by the **NVIDIA Scalable Coherency Fabric (SCF)** ---
a high-bandwidth mesh.

- **One Grace CPU = one NUMA node**
- **One Superchip = two NUMA nodes total**
- Cross-NUMA traffic travels the 900 GB/s NVLink-C2C link

Conventional dual-socket servers may expose four or more NUMA nodes with slow inter-socket interconnects. Grace is
notably simpler.

**Practical rule:** treat each node as two NUMA zones, each with **72 cores** and **\~120 GB of memory**.
:::

::: grid-image
![Left: Grace CPU Superchip with two NUMA nodes linked at 900 GB/s. Right: a conventional dual-socket server for
comparison](/media/NVidia/Grace-CPU-Superchip/image-006-004.png)
:::
:::::

::: notes
- "Two NUMA nodes" is the single most actionable takeaway for attendees
- Tools for NUMA-aware job control: numactl, hwloc/lstopo, Slurm's --mem-per-cpu and --ntasks-per-socket
- The topology comparison image shows Grace (left) vs a conventional dual-socket x86 server (right)
- Do not go deep on SCF internals --- one sentence is enough
:::

## Inside a single Grace CPU die {#grace-cpu-die .shell-slide}

::: slide-subtitle
72 cores, a mesh fabric, and co-packaged LPDDR5X
:::

::::: shell-grid
::: shell-text
### Compute

72 × Arm Neoverse V2 cores

### Cache hierarchy

- **64 KB L1 I-cache + 64 KB L1 D-cache** per core
- **1 MB L2 cache** per core (private)
- **114 MB distributed L3 cache** shared across all 72 cores

### Internal fabric

**3.2 TB/s** NVIDIA Scalable Coherency Fabric connecting cores, L3, memory, and I/O

### Off-die link

**900 GB/s NVLink-C2C** to the second Grace CPU
:::

::: grid-image
![A single Grace CPU die: 72 Neoverse V2 cores, 114 MB L3, 3.2 TB/s SCF fabric, 500 GB/s LPDDR5X, and the NVLink-C2C
link](/media/NVidia/Grace-CPU-Superchip/image-007-006.png)
:::
:::::

::: notes
- 114 MB of shared L3 is very large by server standards --- cache-resident workloads benefit
- 3.2 TB/s is the SCF internal bandwidth, not the external memory bandwidth
- Cache hierarchy for context: L1 (fast, tiny, per-core) → L2 (medium, per-core) → L3 (large, shared) → LPDDR5X
- Most attendees just need to know the cache is generous; detailed tuning is out of scope today
:::

## Memory: LPDDR5X co-packaged for bandwidth {#memory-subsystem .shell-slide}

::: slide-subtitle
240 GB at up to 1 TB/s
:::

:::: shell-grid
::: shell-text
Grace uses **LPDDR5X with ECC**, physically co-packaged with the CPU dies on the same module.

### Capacity

**240 GB total** on this Superchip, split as **2 × 120 GB** --- one 120 GB NUMA node per Grace CPU.

### Bandwidth

  Scope                     Peak bandwidth
  ------------------------- ----------------
  Per Grace CPU             up to 512 GB/s
  Per Grace CPU Superchip   up to 1 TB/s

### Why it matters

Co-packaging eliminates the off-module interconnect bottleneck. The result is unusually high bandwidth for a CPU
platform --- competitive with some HBM-equipped accelerators.

Memory-bandwidth-sensitive codes (FFTs, sparse solvers, molecular dynamics) often benefit the most from Grace.
:::
::::

::: notes
- "Co-packaged" means LPDDR5X chips are on the same substrate as the CPU, not in slots --- this is why bandwidth is so
  high
- 1 TB/s is roughly 3--4× the bandwidth of a dual-socket x86 server using DDR5
- ECC: error-correcting code; standard in HPC; mention only if asked
- Practical takeaway: if a workload is memory-bandwidth bound on x86, it will likely scale well here
:::

## Vectorization: SVE2 and NEON {#vectorization .shell-slide}

::: slide-subtitle
Four 128-bit SIMD units per core
:::

::::: shell-grid
::: shell-text
Each **Neoverse V2 core** contains **four 128-bit SIMD units** supporting two instruction sets.

### NEON

Fixed 128-bit width; the standard Arm SIMD set. Widely supported across compilers and libraries.

### SVE2 (Scalable Vector Extension 2)

Armv9-A feature; also runs at 128 bits on V2, but written length-agnostically so it can target future wider
implementations without recompilation.

### Compiling for best performance

Use `-mcpu=neoverse-v2` with the **GNU compiler** (the recommended path on Isambard 3):

- **GCC:** `-mcpu=neoverse-v2`
- Via Cray wrappers (`cc`, `CC`, `ftn`): add `-mcpu=neoverse-v2` to your flags

`-mcpu` sets both the architecture target and the tuning in one flag --- it is the correct flag for Arm, unlike `-march` which is the x86 convention.
:::

::: grid-image
![Inside a single Neoverse V2 core: 4×128-bit SVE2 SIMD units, L1 caches with parity/ECC, and 1 MB
L2](/media/NVidia/Grace-CPU-Superchip/image-009-010.jpg)
:::
:::::

::: notes
- On V2, SVE2 vector length is fixed at 128 bits --- same physical width as NEON on this chip
- SVE2's length-agnostic programming model means code written for V2 could run unmodified on future wider cores
- The official docs (docs.isambard.ac.uk/user-documentation/guides/modules/) recommend -mcpu=neoverse-v2 with GNU compilers
- Stick to GNU (PrgEnv-gnu / gcc-native): it is the reliable, well-tested path on Isambard 3
- Do not recommend the NVIDIA compiler (NVHPC/nvc): based on practical experience it leads to compilation errors and does not offer a performance advantage; it is not the happy path for most users
- Do not recommend LLVM/Clang or Arm Compiler for Linux here --- they are not the taught route and the docs do not call them out
:::

## Peak FP64 performance: 7.1 TFLOPS {#peak-flops .shell-slide}

::: slide-subtitle
Back-of-the-envelope from first principles
:::

:::: shell-grid
::: shell-text
**Per core, per cycle --- FP64:**

$$\text{FLOPS/cycle per core} = (\text{elements per vector}) \times (\text{vector units}) \times (\text{ops per FMA})$$

$$\text{FLOPS/cycle per core} = 2 \times 4 \times 2 = 16$$

**Scaling to the full Superchip at 3.1 GHz base frequency:**

$$\text{Total FP64 Peak} = 144 \times 3.1 \times 10^{9} \times 16 \approx 7.1 \text{ TFLOPS}$$

NVIDIA's published figure is **7.1 TFLOPS FP64 peak**, consistent with the 3.1 GHz base frequency. At the 3.0 GHz
all-core SIMD frequency the same calculation gives ≈ 6.9 TFLOPS --- the difference is simply which frequency NVIDIA
chose to publish.
:::
::::

::: notes
- Walk through the three-factor calculation step by step if the group is interested; skip fast otherwise
- The 7.1 vs 6.9 TFLOPS gap is purely 3.1 vs 3.0 GHz --- nothing mysterious
- In practice FP64 performance is usually memory-bandwidth bound for HPC codes, not FLOPS bound
- Optional comparison: dual-socket Xeon Platinum 8480+ (112 cores, AVX-512, \~13 TFLOPS) has higher raw peak FP64, but
  Grace leads significantly on memory bandwidth per FLOP
:::

## Grace CPU Superchip: key numbers {#grace-summary .shell-slide}

::: slide-subtitle
What to remember when planning your jobs
:::

::::::::: stat-grid
::: stat-card
[144]{.stat-value} [Arm Neoverse V2 cores per node]{.stat-label}
:::

::: stat-card
[2]{.stat-value} [NUMA nodes per node (72 cores + 120 GB each)]{.stat-label}
:::

::: stat-card
[240 GB]{.stat-value} [LPDDR5X memory per node, with ECC]{.stat-label}
:::

::: stat-card
[1 TB/s]{.stat-value} [peak memory bandwidth per node]{.stat-label}
:::

::: stat-card
[900 GB/s]{.stat-value} [NVLink-C2C between the two CPUs]{.stat-label}
:::

::: stat-card
[7.1 TFLOPS]{.stat-value} [FP64 peak per node]{.stat-label}
:::
:::::::::

::: slide-note
Each node in Isambard 3 is one Grace CPU Superchip. Across 384 nodes: 55,296 cores and \~92 TB of total memory.
:::

::: notes
- Spend 30 seconds on each number and why it matters for job planning
- "Two NUMA nodes": bind MPI ranks and OpenMP threads NUMA-aware for best performance
- "1 TB/s": memory-bandwidth-intensive codes will benefit most from Grace
- "900 GB/s NVLink-C2C": cross-NUMA is cheap here --- much less penalty than on conventional dual-socket
- "7.1 TFLOPS": useful anchor for compute-bound roofline analysis
:::
