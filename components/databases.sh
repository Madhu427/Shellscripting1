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

rabbitmqctl list_users | grep roboshop &>>${LOG_FILE}
if [ $? -ne 0 ]; then
rabbitmqctl add_user roboshop roboshop123 &>>${LOG_FILE}
STAT_CHECK $? "Create user in Rabbit-MQ"
fi

rabbitmqctl set_user_tags roboshop administrator &>>${LOG_FILE}
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${LOG_FILE}
STAT_CHECK $? "Configure APP RabbitMQ User"


# curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo
#
#Install MySQL
## yum install mysql-community-server -y
#
#Start MySQL.
## systemctl enable mysqld
## systemctl start mysqld
#
#Now a default root password will be generated and given in the log file.
## grep temp /var/log/mysqld.log
#
#Next, We need to change the default root password in order to start using the database service.
## mysql_secure_installation
#
#You can check the new password working or not using the following command.
#
## mysql -u root -p
#
#Run the following SQL commands to remove the password policy.
#> uninstall plugin validate_password;
#Setup Needed for Application.
#As per the architecture diagram, MySQL is needed by
#
#Shipping Service
#So we need to load that schema into the database, So those applications will detect them and run accordingly.
#
#To download schema, Use the following command
#
## curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip"
#Load the schema for Services.
#
## cd /tmp
## unzip mysql.zip
## cd mysql-main
## mysql -u root -pRoboShop@1 <shipping.sql


echo -e "\e[1;33m-----------------MYSQL SETUP-----------------\e[0m"

curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>${LOG_FILE}
STAT_CHECK $? "configure yum repos"

yum install mysql-community-server -y &>>${LOG_FILE}
STAT_CHECK $? "Install my sql"

systemctl enable mysqld &>>{LOG_FILE} && systemctl start mysqld &>>${LOG_FILE}
STAT_CHECK $? "Start my-sql service"

DEFAULT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print NF}')

echo 'show databases;' | mysql -uroot -pRoboShop@1 &>>${LOG_FILE}

if [ $? -ne 0 ]; then

  echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';" >/tmp/pass.sql
  mysql --connect-expired-password -uroot -p"${DEFAULT_PASSWORD}" </tmp/pass.sql &>>${LOG_FILE}
  STAT_CHECK $? "Setup new root password"
fi

echo 'show plugins; | mysql -uroot -pRoboShop@1 2>>${LOG_FILE} | grep validate_password &>>${LOG_FILE}'
if [ $? -eq 0 ]; then
  echo "uninstall plugin validate_password" | mysql -u root -p RoboShop@1 &>>${LOG_FILE}
  STAT_CHECK $? "uninstall password plugin"
fi

DOWNLOAD mysql

cd /tmp/mysql-main
mysql -u root -pRoboShop@1 <shipping.sql &>>${LOG_FILE}
STAT_CHECK $? "Schema Installed"