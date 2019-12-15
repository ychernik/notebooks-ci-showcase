#!/bin/bash -u

NOTEBOOK_FILE_NAME="${1}"

NOTEBOOK_GCS_PATH="gs://test-notebooks-ci/${NOTEBOOK_FILE_NAME}"
NOTEBOOK_OUT_GCS_PATH="gs://test-notebooks-ci/out-${NOTEBOOK_FILE_NAME}"

gsutil cp ./demo.ipynb "${NOTEBOOK_GCS_PATH}"

UUID=$(cat /proc/sys/kernel/random/uuid)
JOB_NAME=$(echo "demo-nb-run-${UUID}" | tr '-' '_')
REGION="us-central1"
IMAGE_NAME=$(<container_uri)
gcloud ai-platform jobs submit training "${JOB_NAME}" \
  --region "${REGION}" \
  --master-image-uri "${IMAGE_NAME}" \
  --stream-logs \
  -- nbexecutor \
  --input-notebook "${NOTEBOOK_GCS_PATH}" \
  --output-notebook "${NOTEBOOK_OUT_GCS_PATH}"
  
echo "out: ${NOTEBOOK_OUT_GCS_PATH}"

if [[  $(gcloud ai-platform jobs describe "${JOB_NAME}" | grep "SUCCEEDED") ]]; then
    exit 0
else
    exit 1
fi