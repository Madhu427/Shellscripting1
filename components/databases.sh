#Setup MongoDB repos.
## curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo
#Install Mongo & Start Service.
## yum install -y mongodb-org
## systemctl enable mongod
## systemctl start mongod
#Update Liste IP address from 127.0.0.1 to 0.0.0.0 in config file
#Config file: /etc/mongod.conf
#
#then restart the service
#
## systemctl restart mongod
#Every Database needs the schema to be loaded for the application to work.
#Download the schema and load it.
#
## curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip"
#
## cd /tmp
## unzip mongodb.zip
## cd mongodb-main
## mongo < catalogue.js
## mongo < users.js

LOG_FILE=/tmp/roboshop.log
rm -f ${LOG_FILE}

STAT_CHECK() {

if [ $1 -ne 0 ]; then
  echo -e "\e[1m${2} - /e[1;31mFailed\e[0m"
  exit
else
  echo -e "\e[1m${2} - \e[1;32mSuccess\e[0m"
fi
}

curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>${LOG_FILE}
STAT_CHECK $? "Download Repos.d"


yum install -y mongodb-org &>>${LOG_FILE}
STAT_CHECK $? "Installed Mongodb"

sed -i "s/127.0.0.1/0.0.0.0/" /etc/mongod.conf

systemctl enable mongod &>>${LOG_FILE} && systemctl start mongod &>>${LOG_FILE}
STAT_CHECK $? "Start Mongodb Service"

curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>>${LOG_FILE}
STAT_CHECK $? "Extracted mongodb file"

cd /tmp &>>${LOG_FILE} && unzip -o mongodb.zip &>>${LOG_FILE}
STAT_CHECK $? "Download Mongodb"

cd mongodb-main
mongo < catalogue.js &>>${LOG_FILE} && mongo < users.js &>>${LOG_FILE}
STAT_CHECK $? "Loaded Mongodb Schema"