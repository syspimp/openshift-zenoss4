Zenoss 4.2.5 deploy scripts for Openshift 4.x

Optional: Ansible to automatically discover and add hosts to monitor
Optional: 'oc' client binary somewhere in your path

Why
I enabled SNMP on CoreOS for Openshift and wanted to monitor it using an Open Source tool.

How
I used kompose on a mcroth/docker-zenoss4 docker-compose.yaml file, then edited the persistent volume claims.  I also created two new docker images that merged some ssh patches and mariadb init scripts into a single image.

1. Update the variable.conf file
2. Run deploy.sh
3. Enjoy
