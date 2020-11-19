#!/bin/bash
. variables.conf
oc delete project ${project}
echo sleeping 60 seconds waiting for project to delete, or ctrl-c to skip
sleep 60
