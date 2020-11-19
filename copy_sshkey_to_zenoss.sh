#!/bin/bash
. variables.conf
while /bin/true
do
		oc get pods | grep zenoss4-core | grep Running
		if [[ $? -eq 0 ]]
		then
			break
		fi
done
zenoss_pod=$(oc get pods | grep zenoss4-core | awk '{print $1}')
#oc rsync ssh_fixes/ssh/ ${zenoss_pod}:/opt/zenoss/lib/python/twisted/conch/ssh/
#oc rsync ssh_fixes/test/ ${zenoss_pod}:/opt/zenoss/lib/python/twisted/conch/test/
# copy the ssh key over to zenoss
oc rsh $zenoss_pod mkdir -p /home/zenoss/.ssh
oc rsh $zenoss_pod chown zenoss.zenoss /home/zenoss/.ssh
oc rsh $zenoss_pod chmod 700 /home/zenoss/.ssh
oc cp ${sshkeypath}/${sshkey} $zenoss_pod:/home/zenoss/.ssh/${sshkey}
oc rsh $zenoss_pod chmod 600 /home/zenoss/.ssh/${sshkey}
oc rsh $zenoss_pod chown zenoss.zenoss /home/zenoss/.ssh/${sshkey}
