#!/usr/bin/env/ bash

echo "Enter billing account: "
read bill 

# -- vars
serviceAccount="us-gcp-ame-its-gpt-npd-1@appspot.gserviceaccount.com"
imageFamily="ubuntu-1804-lts"
#imageFamily="ubuntu-1604-lts"
imageProject="ubuntu-os-cloud"
instance="instance-${RANDOM}"
project="us-gcp-ame-its-gpt-npd-1"
zone="us-east4-c"
billing_account="$bill"
email="${project}@${project}.iam.gserviceaccount.com"
startupScript="cloudscript.sh"
subnet="usgcpitsnpd5"
network="usgcpitsnpd4"
# -- my testing folder in dev
#folder="420312749931"
# us-its-npd -- home of the "gpt" test project 
#folder="1072518841216"

# -- provision project and creds if ! exist  
projectExist=$(gcloud projects list |grep "${project}")
if [[ $? > 0 ]]; then 
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

gcloud compute instances create "$instance" \
      --zone="$zone" \
      --service-account="$serviceAccount" \
      --metadata startup-script-url=gs://dcs-cloudscript-new/cloudscript.sh \
      --machine-type=n1-standard-1 \
      --no-address \
      --network="$network" \
      --subnet="$subnet" \
      --image-family="$imageFamily" --image-project="$imageProject" \

gcloud compute instances list |grep "${instance}"
echo "to view console output:"
echo "gcloud compute --project="$project" instances get-serial-port-output "$instance" --zone="$zone" "
echo "or"
echo "gcloud compute --project="$project" instances tail-serial-port-output "$instance" --zone="$zone" "



#    --service-account="$serviceAccount" \
#    --subnet= "$subnet" \
#    --metadata-from-file startup-script=./"$startupScript" \
