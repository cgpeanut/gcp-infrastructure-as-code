#!/usr/env/bash env
set -ex

function folder_roles () {
# define our roles to be applied to our folders
declare -a folder_roles=(
  "roles/resourcemanager.folderAdmin" 
  "roles/bigquery.admin" 
  "roles/cloudfunctions.admin" 
  "roles/cloudkms.admin"
  "roles/cloudsql.admin" 
  "roles/logging.configWriter"
  "roles/pubsub.admin" 
  "roles/iam.serviceAccountUser" 
  "roles/iam.serviceAccountAdmin" 
  "roles/storage.admin")

# add the array of permissions to the folder_id
for role in "${folder_roles[@]}"
do 
gcloud alpha resource-manager folders add-iam-policy-binding ${TF_VAR_folder_id} \
  --member serviceAccount:${TF_SA_NAME}@${TF_ADMIN}.iam.gserviceaccount.com \
  --role "$role" 
done
}
# define our roles to be applied to our orgs
declare -a org_roles=(
  "roles/billing.admin"
  "roles/billing.projectManager"
  "roles/iam.organizationRoleAdmin"
  "roles/iam.securityAdmin" 
  "roles/resourcemanager.projectCreator")
}
# -- create project & set current project as working project
gcloud projects create ${TF_ADMIN} \
  --folder ${TF_VAR_folder_id} --set-as-default
 

# -- link to billing account
gcloud beta billing projects link ${TF_ADMIN} \
  --billing-account ${TF_VAR_billing_account}

 

# -- create the service account
gcloud iam service-accounts create ${TF_SA_NAME} \
  --display-name ${TF_SA_NAME}

 
# -- create service account keys
gcloud iam service-accounts keys create ${TF_CREDS} \
  --iam-account ${TF_SA_NAME}@${TF_ADMIN}.iam.gserviceaccount.com


# add the array of permissions to the folder_id
for role in "${folder_roles[@]}"
do 
gcloud alpha resource-manager folders add-iam-policy-binding ${TF_VAR_folder_id} \
  --member serviceAccount:${TF_SA_NAME}@${TF_ADMIN}.iam.gserviceaccount.com \
  --role "$role" 
done

# -- ENABLE ALL APIS NEEDED 
gcloud services enable bigquery-json.googleapis.com
gcloud services enable bigquerystorage.googleapis.com
gcloud services enable bigtable.googleapis.com
gcloud services enable bigtableadmin.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable cloudapis.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable clouddebugger.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudkms.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudtrace.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable dataflow.googleapis.com
gcloud services enable dataproc.googleapis.com
gcloud services enable datastore.googleapis.com
gcloud services enable deploymentmanager.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable iamcredentials.googleapis.com
gcloud services enable logging.googleapis.com
gcloud services enable monitoring.googleapis.com
gcloud services enable oslogin.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable servicemanagement.googleapis.com
gcloud services enable serviceusage.googleapis.com
gcloud services enable spanner.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable sql-component.googleapis.com
gcloud services enable storage-api.googleapis.com
gcloud services enable storage-component.googleapis.com
gcloud services enable replicapool.googleapis.com
gcloud services enable replicapoolupdater.googleapis.com
gcloud services enable resourceviews.googleapis.com

# -- load up the roles to be applied to the ORG 
for org in "${org_roles[@]}"
do
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:${TF_SA_NAME}@${TF_ADMIN}.iam.gserviceaccount.com \
  --role "$org" 
done

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
