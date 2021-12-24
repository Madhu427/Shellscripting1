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

echo -e "\e[1;33m-----------------MONGODB SETUP-----------------\e[0m"
source components/common.sh


curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>${LOG_FILE}
STAT_CHECK $? "Download Repos.d"


yum install -y mongodb-org &>>${LOG_FILE}
STAT_CHECK $? "Installed Mongodb"

sed -i "s/127.0.0.1/0.0.0.0/" /etc/mongod.conf
STAT_CHECK $? "Update mongodb conf"

systemctl enable mongod &>>${LOG_FILE} && systemctl start mongod &>>${LOG_FILE}
STAT_CHECK $? "Start Mongodb Service"

#curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>>${LOG_FILE}
#STAT_CHECK $? "Extracted mongodb file"

DOWNLOAD mongodb

cd mongodb-main
mongo < catalogue.js &>>${LOG_FILE} && mongo < users.js &>>${LOG_FILE}
STAT_CHECK $? "Loaded Mongodb Schema"




# yum install epel-release yum-utils -y
# yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
# yum-config-manager --enable remi
# yum install redis -y
#Update the BindIP from 127.0.0.1 to 0.0.0.0 in config file /etc/redis.conf & /etc/redis/redis.conf
#
#Start Redis Database

# systemctl enable redis
# systemctl start redis

echo -e "\e[1;33m-----------------REDIS SETUP-----------------\e[0m"

curl -L https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>>${LOG_FILE}
STAT_CHECK $? "Download Redis repo"

yum install redis -y &>>${LOG_FILE}
STAT_CHECK $? "Install Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf &>>${LOG_FILE}
STAT_CHECK $? "Update Redis config"

systemctl enable redis &>>${LOG_FILE} && systemctl start redis &>>${LOG_FILE}

STAT_CHECK $? "Update Redis"


## yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm -y
#Setup YUM repositories for RabbitMQ.
## curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash
#Install RabbitMQ
## yum install rabbitmq-server -y
#Start RabbitMQ
## systemctl enable rabbitmq-server
## systemctl start rabbitmq-server
#RabbitMQ comes with a default username / password as guest/guest. But this user cannot be used to connect. Hence we need to create one user for the application.
#
#Create application user
## rabbitmqctl add_user roboshop roboshop123
## rabbitmqctl set_user_tags roboshop administrator
## rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

echo -e "\e[1;33m-----------------RABBITMQ SETUP-----------------\e[0m"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>${LOG_FILE}
STAT_CHECK $? "Setup RabbitMQ repo"

yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm rabbitmq-server -y &>>${LOG_FILE}
STAT_CHECK $? "Install Erlang & RabbitMQ"


systemctl enable rabbitmq-server &>>{LOG_FILE} && systemctl start rabbitmq-server &>>${LOG_FILE}
STAT_CHECK $? "Start RabbitMQ "

rabbitmqctl add_user roboshop roboshop123 &>>${LOG_FILE}
STAT_CHECK $? "Create user in Rabbit-MQ"
