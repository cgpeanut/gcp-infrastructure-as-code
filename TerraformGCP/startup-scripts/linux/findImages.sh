#!/usr/bin/env bash 
images=($(gcloud compute images list --filter=name=$1))
for each in "${images[@]}"; 
do 
  gcloud compute images describe "$each"
done




