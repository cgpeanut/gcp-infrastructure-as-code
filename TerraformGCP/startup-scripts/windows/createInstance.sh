#!/usr/bin/env bash
set -x 

echo "Enter billing account: "
read bill 

# -- vars
serviceAccount="315217877280-compute@developer.gserviceaccount.com"
#imageFamily="windows-2012-r2"
imageFamily="windows-2016"
imageProject="windows-cloud"
instance="instance-win${RANDOM}"
project="us-gcp-ame-its-gpt-npd-1"
zone="us-east4-c"
billing_account="$bill"
email="${project}@${project}.iam.gserviceaccount.com"
startupScript="cloudscript.sh"
subnet="usgcpitsnpd5"
network="usgcpitsnpd4"

# -- sample inline 
#echo 'Set-Location "C:\"
#
#Set-DnsClientServerAddress -InterfaceIndex 12 -ServerAddresses 10.28.41.208, 10.27.43.60, 10.26.10.80, 10.28.10.80
#
#wget https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi -OutFile C:\puppet-agent-x64-latest.msi
#
#msiexec /qn /norestart /i C:/puppet-agent-x64-latest.msi PUPPET_MASTER_SERVER=uspup-mom.us.deloitte.com PUPPET_AGENT_CERTNAME=HOSTNAME.us.deloitte.com ' | tee startup2.ps1


# -- provision project and creds if ! exist  
projectExist=$(gcloud projects list |grep "${project}")
if [[ $? > 0 ]]; then 
  exit 1
  gcloud projects create "$project" --folder "$folder"
  gcloud config set project "$project" 
  gcloud alpha billing projects link "$project" --billing-account="$billing_account"
  gcloud iam service-accounts create "$project"
  gcloud iam service-accounts keys create "$project".key.json --iam-account="$email"
  gcloud config list
  gcloud config set project "$project" 
else 
  echo skipped...."${project}" exists 
fi

gcloud config set project "${project}"
gcloud compute instances create $instance \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --zone="$zone" \
  --service-account="$serviceAccount" \
  --metadata=windows-startup-script-url=gs://dcs-cloudscript-new/cloudscript-new.ps1 \
  --machine-type=n1-standard-2 \
  --no-address \
  --image-family="$imageFamily" \
  --image-project="$imageProject" \
  --network="$network" \
  --subnet="$subnet" \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --reservation-affinity=any 

gcloud compute instances list |grep "${instance}"
echo "to view console output:"
echo "gcloud compute --project="$project" instances get-serial-port-output "$instance" --zone="$zone" "
echo "or"
echo "gcloud compute --project="$project" instances tail-serial-port-output "$instance" --zone="$zone" "


#--metadata-from-file windows-startup-script-ps1="startup2.ps1" \
