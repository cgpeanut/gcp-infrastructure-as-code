# to install
1. clone this repo to your local cloudshell: git clone https://github.com/cgpeanut/gcp-infrastructure-as-code.git
3. fill out the .sample_envrc with project details    # -- no need to source, this is taken care of in the bootstrap script
4. run "bash -x bootstrap.sh" 
5. cd ./terraform-google-forseti/examples/install-simple
6. Open the terraform.tfvars, add projectID and orgID from your .sample_envrc
7. Run "terraform init" then run "terraform plan" and finally "terrafrom apply" 