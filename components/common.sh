LOG_FILE=/tmp/roboshop.log
rm -f ${LOG_FILE}

MAX_LENGTH=$(cat components/*.sh  | grep -v -w cat | grep STAT_CHECK | awk -F '"' '{print $2}' | awk '{print length}'| sort | tail -1)


if [ ${MAX_LENGTH} -lt 27 ]; then
   MAX_LENGTH=27
fi


STAT_CHECK() {

  SPACE=""
  LENGTH=$(echo $2 | awk '{print length}')
  LEFT=$((${MAX_LENGTH}-${LENGTH}))
    while [ $LEFT -gt 0 ]; do
      SPACE=$(echo -n "${SPACE} ")
      LEFT=$((${LEFT}-1))
    done

if [ $1 -ne 0 ]; then
  echo -e "\e[1m${2}${SPACE}- \e[1;31mFailed\e[0m"
  exit
else
  echo -e "\e[1m${2}${SPACE}- \e[1;32mSuccess\e[0m"
fi
}


DOWNLOAD() {
  curl -s -L -o /tmp/${1}.zip "https://github.com/roboshop-devops-project/${1}/archive/main.zip" &>>${LOG_FILE}
  STAT_CHECK $? "download ${1} code"
  cd /tmp

  unzip -o /tmp/${1}.zip &>>${LOG_FILE}

  STAT_CHECK $? "extract ${1} code"

}

NODEJS() {
  component=${1}
  yum install nodejs make gcc-c++ -y &>>${LOG_FILE}
  STAT_CHECK $? "INSTALL Node JS"

  id roboshop &>>${LOG_FILE}
  if [ $? -ne 0 ]; then
  useradd roboshop &>>${LOG_FILE}
  STAT_CHECK $? "User added"
  fi


  DOWNLOAD ${component}

  rm -rf /home/roboshop/${component} && mkdir -p /home/roboshop/${component} && cp -r /tmp/${component}-main/* /home/roboshop/${component}


  &>>{LOG_FILE}
  STAT_CHECK $? "Copy ${component} content"

  cd /home/roboshop && npm install --unsafe-perm &>>{LOG_FILE}
  STAT_CHECK $? "Install ${component} dependencies"

  chown roboshop:roboshop -R /home/roboshop

  sed -i -e 's/MONGO_DNSNAME/mongodb1.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis1.roboshop.internal/'  -e 's/MONGO_ENDPOINT/mongodb1.roboshop.internal/' /home/roboshop/${component}/systemd.service &>>${LOG_FILE} &&  mv /home/roboshop/${component}/systemd.service /etc/systemd/system/${component}.service
  STAT_CHECK $? "update entries in systemd file"

  systemctl daemon-reload &>>{LOG_FILE} && systemctl start ${component} &>>{LOG_FILE} && systemctl enable ${component} &>>{LOG_FILE}
  STAT_CHECK $? "Start ${component} Service"

}

 JAVA() {

  yum install maven -y &>>${LOG_FILE}
  STAT_CHECK $? "Installing Maven"

  APP_USER_SETUP() {
      id roboshop &>>${LOG_FILE}
      if [ $? -ne 0 ]; then
        useradd roboshop &>>${LOG_FILE}
        STAT_CHECK $? "Add Application user"
  }

  cd /home/roboshop/${component} && mvn clean package &>>${LOG_FILE} && mv target/${component}-1.0.jar ${component}.jar &>>{LOG_FILE}
  STAT_CHECK "compile java code"
}