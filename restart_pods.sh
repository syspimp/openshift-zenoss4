#!/bin/bash -x
namespace=monitoring
app=zenoss4
which oc > /dev/null 2> /dev/null
if [[ $? -eq 0 ]]
then
  # this is untested, commandline might be wrong
  echo -e "\nStopping ${app} ..."
  for deploy in `oc get deploy -n ${namespace} | grep ${app} | awk '{print $1}'`;
  do
    oc scale deploy ${deploy} --replicas=0 -n ${namespace}
    sleep 1
  done
  
  echo -e "\nStarting ${app} ..."
  
  for deploy in `oc get deploy -n ${namespace} | grep ${app} | awk '{print $1}'`;
  do
    oc scale deploy ${deploy} --replicas=1 -n ${namespace}
    sleep 1
  done
  exit 0
fi
which kubectl > /dev/null 2> /dev/null
if [[ $? -eq 0 ]]
then
  echo -e "\nStopping ${app} ..."
  for deploy in `kubectl get deploy -n ${namespace} | grep ${app} | awk '{print $1}'`;
  do
    kubectl scale deploy ${deploy} --replicas=0 -n ${namespace}
    sleep 1
  done
  
  echo -e "\nStarting ${app} ..."
  
  for deploy in `kubectl get deploy -n ${namespace} | grep ${app} | awk '{print $1}'`;
  do
    kubectl scale deploy ${deploy} --replicas=1 -n ${namespace}
    sleep 1
  done
  exit 0
else
  echo -e "\nYou need a kubernetes client installed. Install openshift client 'oc' or kubectl\n\n"
  exit 1
fi




