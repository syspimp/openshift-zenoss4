#!/bin/bash
zenoss_pod=$(oc get pods | grep zenoss4-core | awk '{print $1}')
oc rsh $zenoss_pod
