#!/bin/bash
sudo apt update -y
if ! [ -x "$(command -v apache2 -v)" ]; then
  sudo apt install apache2
fi
servstat=$(service apache2 status)
if [[ $servstat != *"active (running)"* ]]; then
  sudo service apache2 start
fi
timestamp=$(date '+%d%m%Y-%H%M%S')
#echo "${timestamp}.tar"
myname="varun"
tar cvf /tmp/"${myname}-httpd-logs-${timestamp}.tar" /var/log/apache2/*.log

s3_bucket="upgrad-varun"
aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
