#!/usr/bin/env bash
gsutil cp cloudscript.sh gs://dcs-cloudscript/
gsutil acl ch -u AllUsers:R gs://dcs-cloudscript/cloudscript.sh

