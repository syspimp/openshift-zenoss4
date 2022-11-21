#!/bin/bash -x
which oc > /dev/null 2> /dev/null
if [[ $? -eq 0 ]]
then
  zenoss_pod=$(oc get pods | grep zenoss4-core | awk '{print $1}')
  oc rsh $zenoss_pod
  exit 0
fi
which kubectl > /dev/null 2> /dev/null
if [[ $? -eq 0 ]]
then
  zenoss_pod=$(kubectl -n monitoring get pods | grep zenoss4-core | awk '{print $1}')
  kubectl exec -n monitoring -i -t ${zenoss_pod} -- bash
  exit 0
else
  echo -e "\nYou need a kubernetes client installed. Install openshift client 'oc' or kubectl\n\n"
  exit 1
fi
