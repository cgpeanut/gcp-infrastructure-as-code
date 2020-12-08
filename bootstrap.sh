#!/usr/env/bash env
set -ex

# -- source env vars
source ./.envrc 

# -- terraform installation 
installTerraform () {
  if [[ ! $(command -v terraform) ]]; then 
    sudo apt-get install unzip zip -y
    cd /tmp
    wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
    unzip terraform*.zip
    chmod +x terraform*
    # this adds terraform to the path
    sudo mv terraform /usr/local/bin/terraform
  fi

}
# -- clone forseti IF !
cloneForseti () { 
  cd $HOME/forseti
  if [[ ! -d ./terraform-google-forseti ]]; then
    git clone --branch modulerelease502 --depth 1 https://github.com/forseti-security/terraform-google-forseti.git 
  fi

}




createProject () {

# define our roles to be applied to our folders
declare -a folder_roles=(
  "roles/owner"
  "roles/compute.instanceAdmin"
  "roles/compute.networkViewer"
  "roles/compute.securityAdmin"
  "roles/iam.serviceAccountAdmin"
  "roles/serviceusage.serviceUsageAdmin"
  "roles/iam.serviceAccountUser"
  "roles/storage.admin"
  "roles/cloudsql.admin")

# define our roles to be applied to our orgs
declare -a org_roles=(
  "roles/resourcemanager.organizationAdmin"
  "roles/iam.securityReviewer")

# -- create project & set current project as working project
gcloud projects create ${TF_VAR_project_id} \
  --folder ${TF_VAR_folder_id} --set-as-default
 

# -- link to billing account
gcloud beta billing projects link ${TF_VAR_project_id} \
  --billing-account ${TF_VAR_billing_account}
 
# -- ENABLE ALL APIS NEEDED 
gcloud services enable compute.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable serviceusage.googleapis.com

## create a bucket inside our project to capture .envrc & .json creds
gsutil mb -p ${TF_VAR_project_id} gs://${TF_VAR_project_id}
###
cat > backend.tf << EOF
terraform {
 backend "gcs" {
   bucket  = "${TF_VAR_project_id}"
   prefix  = "${TF_VAR_project_id}/state"
 }
}
EOF
## -- enable versioning
gsutil versioning set on gs://${TF_VAR_project_id}

##-- copy secure files to bucket
gsutil cp ./.envrc gs://${TF_VAR_project_id}

# -- run the helper script
source ./terraform-google-forseti/helpers/setup.sh -p $TF_VAR_project_id -o $TF_VAR_org_id

# -- backup the creds file
gsutil cp ./credentials.json gs://${TF_VAR_project_id}

}

# -- call functions 
installTerraform 
cloneForseti
createProject
