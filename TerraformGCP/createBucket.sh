#!/usr/bin/env bash
set -ex
# create a bucket inside our project to capture .envrc & admin.json creds
gsutil mb -p ${TF_ADMIN} gs://${TF_ADMIN}
#
cat > backend.tf << EOF
terraform {
 backend "gcs" {
   bucket  = "${TF_ADMIN}"
   prefix  = "${TF_ADMIN}/state"
 }
}
EOF
## -- enable versioning
gsutil versioning set on gs://${TF_ADMIN}
#-- copy secure files to bucket
gsutil cp .envrc gs://${TF_ADMIN}
gsutil cp ${TF_ADMIN}.json gs://${TF_ADMIN}
