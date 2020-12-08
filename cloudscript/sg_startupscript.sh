#!/usr/bin/env bash
set -x 
file=/etc/login.defs

function collect_projects () {
  # -- collect a clean project name 
  project=($(gcloud config get-value project))
  counter="${#project[@]}"

}

# -- to be used in the event we need hard coded sg's
function set_static_sgs () { 
  # -- source file	

  # -- array of sg's that need to be applied, list can be appended 
  sg=("us-gcp-test-again-test-prd" "us-gcp-test-this")
  counter="${#sg[@]}"

  # -- loop through the list of sg's 
  for ((i = 0; i < "$counter"; i++)); 
  do
    grep -qF "${sg[$i]}" "$file" || echo "${sg[$i]}" | sudo tee -a "$file"
  done

}  


function set_dynamic_sgs () { 
  # -- format and build new array 
  for each in "${project[@]}";
  do
  	projects_formatted+=($(echo "${each}" | tr '-' '_'))
  done
  
  # -- print new array
  for i in "${projects_formatted[@]}";
  do
    grep -qF sg_"${projects_formatted[$i]}"_devops "$file" || echo sg_"${projects_formatted[$i]}"_devops | sudo tee -a "$file"
  done
}
# -- run in order
collect_projects 
# -- activate if you need static sgs
#set_static_sgs
set_dynamic_sgs
