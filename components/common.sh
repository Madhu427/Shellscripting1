LOG_FILE=/tmp/roboshop.log
rm -f ${LOG_FILE}


STAT_CHECK() {

if [ $1 -ne 0 ]; then
  echo -e "\e[1m${2} - \e[1;31mFailed\e[0m"
  exit
else
  echo -e "\e[1m${2} - \e[1;32mSuccess\e[0m"
fi
}

DOWNLOAD() {
  curl -s -L -o /tmp/mongodb${1}.zip "https://github.com/roboshop-devops-project/${1}/archive/main.zip" &>>${LOG_FILE}
  STAT_CHECK $? "download ${1} code"
  cd /tmp &>>${LOG_FILE} && unzip -o ${1}.zip &>>${LOG_FILE}
  STAT_CHECK $? "extract ${1} code"

}