**Understanding the NVIDIA Grace CPU Superchip**

Welcome! As you start submitting your first jobs, it is helpful to understand the hardware under the hood. Unlike
traditional x86 clusters you might have used in the past, this system is powered by the **NVIDIA Grace CPU Superchip**.

This architecture brings some unique advantages to high-performance computing (HPC) workflows, especially regarding
memory bandwidth, topology, and ease of programming. Here is a practical breakdown of what you are working with.

## **The Big Picture: What is a “Superchip”?**

When we say “Superchip,” we are talking about two separate NVIDIA Grace CPUs tightly packaged together on a single
board.

- **The Cores:** Across the Superchip, you have access to **144 Arm Neoverse V2 cores** (72 cores per CPU). These are
  64-bit Armv9-A cores, meaning they share the same base architecture family as the chips in modern smartphones or Apple
  Silicon Macs, but scaled up massively for the data center.

- **The Interconnect:** The two CPUs are joined by a dedicated connection called **NVLink-C2C** (Chip-to-Chip). This
  acts as a massive data highway between the two halves of the chip, offering **900 GB/s** of bi-directional bandwidth.

## **Topology and the NUMA Layout**

If you are coming from traditional x86 servers, you might be familiar with ring or torus topologies that can create
multiple non-uniform memory access (NUMA) domains even within a single die. The Grace CPU design handles this
differently.

- **The Scalable Coherency Fabric (SCF):** Instead of a ring, each 72-core Grace CPU relies on a 2D mesh network called
  the NVIDIA Scalable Coherency Fabric (SCF). The CPU cores and distributed cache partitions are spread evenly
  throughout this mesh.

- **No Internal NUMA:** Because this mesh provides a staggering **3.2 TB/s of bisection bandwidth** per chip, data flows
  incredibly fast between the cores, cache, and memory. As a result, all 72 cores on a single die have uniform access to
  the memory attached to that die. There is no sub-NUMA clustering—**each 72-core CPU acts as exactly one NUMA node**.

- **The Superchip NUMA:** Across the entire Superchip, you only have to manage **two NUMA nodes** in total (one for each
  die). The 900 GB/s NVLink-C2C connection between them is so fast that it heavily minimizes the penalty for crossing
  domains compared to traditional dual-socket servers.

- **Memory:** The chip tackles memory bottlenecks by using server-class **LPDDR5X** memory co-packaged directly with the
  CPUs. These nodes feature **2 × 120 GB** of memory (240 GB total), delivering up to 512 GB/s of bandwidth per CPU with
  exceptional power efficiency.

## **Vectorization: How It Crunches Numbers**

To get maximum performance out of HPC code, you need to leverage vectorization—performing the same operation on multiple
pieces of data simultaneously (SIMD).

- **The Vector Units:** Each Neoverse V2 core has **four 128-bit functional units**.

- **The Instruction Set:** These units support both NEON and the newer **Scalable Vector Extension version 2 (SVE2)**.
  SVE2 is fantastic for scientific codes, machine learning, and bioinformatics. Each of the four units can retire either
  SVE2 or NEON instructions.

- **Compiling:** To take advantage of this, ensure you compile your code targeting the Armv9 ISA and tune for the
  Neoverse V2 microarchitecture. Modern open-source or vendor compilers (like GCC, LLVM, and NVHPC) can auto-vectorize
  your code to utilize SVE2.

## **Calculating FLOPS (Floating-Point Operations Per Second)**

For those looking to understand the theoretical limits of their code, here is how we calculate the raw compute
throughput per core and per chip.\
The official peak double-precision (FP64) performance of the Superchip is **7.1 TFLOPS**. Let’s break down how many
FLOPS you get per clock cycle.

**Per-Core FP64 Math:**

1.  **Vector Length:** 128 bits.

2.  **Data Size:** A double-precision float (FP64) is 64 bits. Therefore, each vector holds $`128 / 64 = 2`$ FP64
    elements.\

3.  **Functional Units:** There are 4 units per core.

4.  **FMA:** Using Fused Multiply-Add instructions (which perform an addition and a multiplication in one step), you get
    2 operations per element.

Using standard calculations for theoretical peak performance:

``` math
\text{FLOPS/cycle per core} = (\text{Elements per vector}) \times (\text{Vector units}) \times (\text{Operations per FMA})
```

``` math
\text{FLOPS/cycle per core} = 2 \times 4 \times 2 = 16 \text{ FP64 operations per clock cycle}
```
\
**Total Superchip Performance:** The all-core SIMD frequency is **3.0 GHz**.

``` math
\text{Total FP64 Peak} = 144 \text{ cores} \times 3.0 \times 10^9 \text{ cycles/sec} \times 16 \text{ FLOPS/cycle}
```

``` math
\text{Total FP64 Peak} \approx 6.91 \text{ TFLOPS}
```

(Note: The advertised 7.1 TFLOPS peak factors in the base frequency of 3.1 GHz rather than the slightly lower 3.0 GHz
SIMD frequency).

**Summary for your code:** If your code is fully vectorized and utilizing FMA instructions, you can theoretically
squeeze 16 double-precision operations out of every single core, every single clock cycle.
