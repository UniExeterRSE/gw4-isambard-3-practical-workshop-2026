#!/bin/bash

set -euo pipefail

module reset
module load PrgEnv-gnu

make all
