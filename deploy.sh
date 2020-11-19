#!/bin/bash
# deploy zenoss 4.2.5 to Openshift 4.x
# update the variables.conf to match your environment
# stop on errors
set -e
# debug script
#set -x

. variables.conf

which oc >/dev/null 2>/dev/null
if [[ $? -ne 0 ]]
then
  echo "** you need to download and put the oc client in your PATH, and log into your openshift cluster to continue"
	exit 1
fi

echo "** creating new project ${project}"
oc new-project ${project}

echo
echo "** updating scc for container to have root access"
oc adm policy add-scc-to-user anyuid -z default

echo
echo "** creating volume claims"
for i in *claim*yaml; do echo working on $i ; oc apply -f $i ; done ;
sleep 5

echo
echo "** creating configuration files"
for i in *configmap*yaml; do echo working on $i ; oc apply -f $i ; done ;

echo
echo "** deploying containers/pods"
for i in *deployment*yaml; do echo working on $i ; oc apply -f $i ; done ;

echo
echo "** mapping services to pods"
for i in *service*yaml; do echo working on $i ; oc apply -f $i ; done ;

echo
echo "** exposing a route to the nginx frontend"
oc expose svc/zenoss4-nginx

echo
echo "** deploying sshkey to zenoss if not variable empty"
if [[ "$sshkey" != "" ]]
then
  ./copy_sshkey_to_zenoss.sh
else
	echo "** fill out sshkey variable in variables.conf to copy a private sshkey to zenoss"
fi

# use ansible to add hosts to zenoss
rpm -qa | grep ansible >/dev/null 2>/dev/null
if [[ $? -eq 0 ]]
then
  # add hosts to monitor
  echo
  echo "** sleeping 120 seconds for zenoss to wake up to add hosts"
  sleep 120
  ansible-playbook addhost_to_zenoss.yml
else
	echo "** install ansible and run 'ansible-playbook addhost_to_zenoss.yml' to monitor your hosts"
	echo "** or source the zenoss_api.sh script to add hosts"
	echo "Example:"
	echo "\$ source ./zenoss_api.sh" 
  echo "\$ zenoss_api \"device_router\" \"DeviceRouter\" \"getProductionStates\" '{}'"
	echo "{\"uuid\": \"0c089834-f2d7-4fda-8588-4710b6e8aefd\", \"action\": \"DeviceRouter\",\"result\": {\"data\": [{\" ...."
fi

