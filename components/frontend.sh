#!/bin/bash

# yum install nginx -y
# systemctl enable nginx
# systemctl start nginx
#Let's download the HTML content that serves the RoboSHop Project UI and deploy under the Nginx path.

# curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip"
#Deploy in Nginx Default Location.

# cd /usr/share/nginx/html
# rm -rf *
# unzip /tmp/frontend.zip
# mv frontend-main/* .
# mv static/* .
# rm -rf frontend-master static README.md
# mv localhost.conf /etc/nginx/default.d/roboshop.conf
#Finally restart the service once to effect the changes.

# systemctl restart nginx
source components/common.sh

LOG_FILE=/tmp/roboshop.log
rm -f ${LOG_FILE}


yum install nginx -y &>>${LOG_FILE}

STAT_CHECK $? "Nginx installation"

#curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>${LOG_FILE}
#STAT_CHECK $? "Download Front-end"

DOWNLOAD frontend

rm -rf /usr/share/nginx/html/*
STAT_CHECK $?  "Remove Old HTML Files"

#cd /tmp && unzip -o /tmp/frontend.zip &>>${LOG_FILE}
#STAT_CHECK $? "Extracting Front-end content"

cd /tmp/frontend-main/static/ && cp -r * /usr/share/nginx/html/
STAT_CHECK $? "Copying frontend content"

cp /tmp/frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf
STAT_CHECK $? "Update Nginx Config file"

systemctl enable nginx &>>${LOG_FILE} && systemctl restart nginx &>>${LOG_FILE}
STAT_CHECK$? "Nginx Restarted" &>>${LOG_FILE}