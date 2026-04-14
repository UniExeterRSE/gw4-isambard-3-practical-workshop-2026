# Stretch Goal: Swapping Compilers via Modules

While Isambard 3 works well with pre-built software or Python, you may eventually need to compile software from source
code (e.g., C, C++, or Fortran).

The supercomputers typically provide different programming environments. If a build fails or perform poorly on the Grace
CPUs (AARCH64 architecture), swapping the compiler is often the first step.

## Check the default compiler

``` bash
module reset
which gcc
gcc --version
```

You might find that the default compiler is somewhat old, which might not have full support for modern AARCH64 features.

## Load a newer compiler environment

On BriCS systems like Isambard 3, alternate compilers are often packaged as Programming Environments (e.g.,
`PrgEnv-gnu`).

``` bash
module load PrgEnv-gnu
module list
```

Now check the compiler again:

``` bash
which gcc
gcc --version
```

You should see a newer version of GCC (for example, GCC 14.x) provided by a `gcc-native` module that was automatically
loaded as a dependency of `PrgEnv-gnu`.

## Key Takeaway

If you are compiling software or dealing with complex build tools that behave unexpectedly on Isambard 3, swapping the
background compiler via standard modules is the recommended approach before diving into deep configuration fixes.
