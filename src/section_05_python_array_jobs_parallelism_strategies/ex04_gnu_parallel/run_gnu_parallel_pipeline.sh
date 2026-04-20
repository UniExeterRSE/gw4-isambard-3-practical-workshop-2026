#!/bin/bash
# Submit the GNU-parallel pipeline: pre -> parallel -> post.
# Run on the login node: bash run_gnu_parallel_pipeline.sh
# Each stage only starts when the previous one succeeds (afterok).
set -euo pipefail

PRE_JOB_ID=$(sbatch --parsable sbatch_pre_gnu_parallel.sh)
echo "Pre:  ${PRE_JOB_ID}"

MAIN_JOB_ID=$(sbatch --parsable \
    --dependency=afterok:${PRE_JOB_ID} \
    sbatch_gnu_parallel.sh)
echo "Main: ${MAIN_JOB_ID} (waits for ${PRE_JOB_ID})"

POST_JOB_ID=$(sbatch --parsable \
    --dependency=afterok:${MAIN_JOB_ID} \
    sbatch_post_gnu_parallel.sh)
echo "Post: ${POST_JOB_ID} (waits for ${MAIN_JOB_ID})"

echo
echo "Pipeline queued. Monitor with: squeue --me"
