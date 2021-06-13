#!/bin/bash
# deploy zenoss 4.2.5 to Openshift 4.x
# update the variables.conf to match your environment
# stop on errors
#set -e
# debug script
#set -x

. variables.conf

echo "** if you get errors with the oc client, try export KUBECONFIG=blah/blah/kubeconfig or logging into ocp with the oc binary"
sleep 5

which oc >/dev/null 2>/dev/null
if [[ $? -ne 0 ]]
then
  echo "** you need to download and put the oc client in your PATH, and log into your openshift cluster to continue"
	exit 1
fi

echo "** creating new project ${project}"
oc new-project ${project} || true

echo
echo "** updating scc for container to have root access"
oc adm policy add-scc-to-user anyuid -z default

echo
echo "** creating volume claims"
for i in objects/*claim*yaml; do echo working on $i ; oc apply -f $i ; done ;
sleep 5

echo
echo "** creating configuration files"
for i in objects/*configmap*yaml; do echo working on $i ; oc apply -f $i ; done ;

echo
echo "** deploying containers/pods"
for i in objects/*deployment*yaml; do echo working on $i ; oc apply -f $i ; done ;

echo
echo "** mapping services to pods"
for i in objects/*service*yaml; do echo working on $i ; oc apply -f $i ; done ;

echo
echo "** exposing a route to the nginx frontend"
oc expose svc/zenoss4-nginx

echo
echo "** waiting for the zenoss-core pod to have status running"
while /bin/true
do
		oc get pods | grep zenoss4-core | grep Running
		if [[ $? -eq 0 ]]
		then
			break
		fi
done

zenoss_pod=$(oc get pods | grep zenoss4-core | awk '{print $1}')
echo
echo "** deploying sshkey to zenoss if not variable empty"
if [[ "$sshkey" != "" ]]
then
  echo
  echo "** copy the ssh key to zenoss pod"
  oc rsh $zenoss_pod mkdir -p /home/zenoss/.ssh
  oc rsh $zenoss_pod chown zenoss.zenoss /home/zenoss/.ssh
  oc rsh $zenoss_pod chmod 700 /home/zenoss/.ssh
  oc cp ${sshkeypath}/${sshkey} $zenoss_pod:/home/zenoss/.ssh/${sshkey}
  oc rsh $zenoss_pod chmod 600 /home/zenoss/.ssh/${sshkey}
  oc rsh $zenoss_pod chown zenoss.zenoss /home/zenoss/.ssh/${sshkey}
else
	echo "** fill out sshkey variable in variables.conf to copy a private sshkey to zenoss"
fi

echo
echo "** fixing permissions on /opt/zenoss/perf"
echo "** needed if one wants persistent graphs and use pvc"
echo "** if you dont use a pvc, you lose graphing data if the pod is restarted on another node"
oc rsh $zenoss_pod chown zenoss.zenoss /opt/zenoss/perf

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

