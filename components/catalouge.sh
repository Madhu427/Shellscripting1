#This service is responsible for showing the list of items that are to be sold by the RobotShop e-commerce portal.
#
#This service is written in NodeJS, Hence need to install NodeJS in the system.
#
## yum install nodejs make gcc-c++ -y
#Let's now set up the catalogue application.
#
#As part of operating system standards, we run all the applications and databases as a normal user but not with root user.
#
#So to run the catalogue service we choose to run as a normal user and that user name should be more relevant to the project. Hence we will use roboshop as the username to run the service.
#
## useradd roboshop
#So let's switch to the roboshop user and run the following commands.
#
#$ curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip"
#$ cd /home/roboshop
#$ unzip /tmp/catalogue.zip
#$ mv catalogue-main catalogue
#$ cd /home/roboshop/catalogue
#$ npm install
#NOTE: We need to update the IP address of MONGODB Server in systemd.service file
#Now, lets set up the service with systemctl.
#
## mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
## systemctl daemon-reload
## systemctl start catalogue
## systemctl enable catalogue

source components/common.sh

yum install nodejs make gcc-c++ -y &>>${LOG_FILE}
STAT_CHECK $? "INSTALL Node JS"

id roboshop &>>${LOG_FILE}
if [ $? -ne 0 ]; then
useradd roboshop &>>${LOG_FILE}
STAT_CHECK $? "User added"
fi

DOWNLOAD catalogue

rm -rf /home/roboshop/catalogue && mkdir -p /home/roboshop/catalogue && cp -r /tmp/catalogue-main/* /home/roboshop/catalogue
&>>{LOG_FILE}
STAT_CHECK $? "Copy catalogue content"

cd /home/roboshop && npm install --unsafe-perm &>>{LOG_FILE}
STAT_CHECK $? " Install node js dependencies"

chown roboshop:roboshop -R /home/roboshop

sed -i "s/MONGO_DNSNAME/mongo.devopsrobshop.com/" /home/roboshop/catalogue/systemd.service &>>${LOG_FILE} &&  mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
STAT_CHECK $? "update entries in systemd file"

systemctl daemon-reload &>>{LOG_FILE} && systemctl start catalogue &>>{LOG_FILE} && systemctl enable catalogue &>>{LOG_FILE}
STAT_CHECK $? "Start Catalogue Service"
#curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>${LOG_FILE}
#STAT_CHECK $? "Download catalouge"
#
#cd /home/roboshop && unzip -o /tmp/catalogue.zip &>>${LOG_FILE}
#STAT_CHECK $? "moved catalogue to home"
#
#mv catalogue-main catalogue &>>${LOG_FILE} && sudo cd /home/roboshop/catalogue &>>${LOG_FILE}
#
#npm install &>>${LOG_FILE}
#STAT_CHECK $? "Catalouge Installed"
