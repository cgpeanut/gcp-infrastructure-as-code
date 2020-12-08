#!/usr/bin/env bash 
set -x
gcloud compute instances add-metadata instance-1 \
    --metadata-from-file startup-script=./sg_startupscript.sh

