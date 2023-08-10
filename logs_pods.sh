#!/bin/bash -x
kubebin=kubectl
namespace=monitoring
app=zenoss4

which oc > /dev/null 2> /dev/null
if [[ $? -eq 0 ]]
then
  # this is untested, commandline might be wrong
  kubebin=oc
fi
which kubectl > /dev/null 2> /dev/null
if [[ $? -ne 0 && "${kubebin}" != "oc" ]]
then
  echo -e "\nYou need a kubernetes client installed. Install openshift client 'oc' or kubectl\n\n"
  exit 1
fi

for pod in `${kubebin} -n ${namespace} get pod | grep ${app} | awk '{print $1}'`;
do
  echo "Pod: ${pod} ****************************************************************"
  ${kubebin} -n ${namespace} logs ${pod}
done
exit 0
