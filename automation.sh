#!/bin/bash
sudo apt update -y
if ! [ -x "$(command -v apache2 -v)" ]; then
  sudo apt install apache2
fi
servstat=$(service apache2 status)
if [[ $servstat != *"active (running)"* ]]; then
  sudo service apache2 restart
fi

FILE=/var/www/html/inventory.html
if  [[ ! -f "$FILE" ]]; then
	echo "Log Type      Time Created     Type    Size" > /var/www/html/inventory.html
fi

timestamp=$(date '+%d%m%Y-%H%M%S')
#echo "${timestamp}.tar"
myname="varun"
tar cvf /tmp/"${myname}-httpd-logs-${timestamp}.tar" /var/log/apache2/*.log

s3_bucket="upgrad-varun"
FILENAME=/tmp/${myname}-httpd-logs-${timestamp}.tar
FILESIZE=$(stat -c%s "$FILENAME")

aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
if  [[  -f "$FILE" ]]; then
        echo "httpd-logs    $timestamp     tar    $FILESIZE" >> /var/www/html/inventory.html
fi
CRON=/etc/cron.d/automation
if  [[ ! -f "$CRON" ]]; then
        echo "* * * * * root bash /root/Automation_Project/automation.sh" > /etc/cron.d/automation
fi
