#!/usr/bin/env bash
# -- grab list of instances in the project selected
gcloud compute instances list --format='value[separator=","](name,zone)'

# -- formatting
var="before,after"
before="${var%,*}"
after="${var#*,}"

# -- loop the instances and ssh remote command
for instance in $(gcloud compute instances list --format='value[separator=","](name,zone)'); do
  name="${instance%,*}";
  zone="${instance#*,}";
  gcloud compute ssh $name --zone=$zone --command="sudo apt-get install puppet -y"
done


