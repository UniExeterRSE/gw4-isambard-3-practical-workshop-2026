#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# need these for bootstrap
# __OPT_ROOT
# MAMBA_ROOT_PREFIX
# XDG_CONFIG_HOME

# follow .bashrc logic but point to PROJECTDIR
read -r __OSTYPE __ARCH <<< "$(uname -sm)"
export __OSTYPE __ARCH
# __LOCAL_ROOT <- arch-indep software prefix
export __LOCAL_ROOT="${PROJECTDIR}/local"
# __OPT_ROOT <- arch-dep software prefix
export __OPT_ROOT="${__LOCAL_ROOT}/opt/${__OSTYPE}-${__ARCH}"
export MAMBA_ROOT_PREFIX="${__OPT_ROOT}/miniforge3"
export XDG_CONFIG_HOME="${PROJECTDIR}/local/config"

echo "__LOCAL_ROOT=${__LOCAL_ROOT}"
echo "__OPT_ROOT=${__OPT_ROOT}"
echo "MAMBA_ROOT_PREFIX=${MAMBA_ROOT_PREFIX}"
echo "XDG_CONFIG_HOME=${XDG_CONFIG_HOME}"

cd "${DIR}/../../bootstrap"
install/bootstrap.sh

mamba env create -f "${DIR}/../../environment_hpc.yml" -p "${__OPT_ROOT}/isambard3-workshop-hpc" -y
echo mamba activate "${__OPT_ROOT}/isambard3-workshop-hpc"
