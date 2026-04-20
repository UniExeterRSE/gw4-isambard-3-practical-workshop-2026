# Instructions to create a fallback stack

In case anyone cannot follow the instructions to set it up fully.

Bootstrap everything:

``` sh
./maintainer.sh
```

Somehow the miniforge3 isn’t installed correctly, as a temporary fix:

``` sh
# from repo root
cd bootstrap
MAMBA_ROOT_PREFIX="${PROJECTDIR}/local/opt/Linux-aarch64/miniforge3" install/mamba.sh install
```
