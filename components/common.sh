LOG_FILE=/tmp/roboshop.log
rm -f ${LOG_FILE}

MAX_LENGTH=$( cat components/databases.sh  | grep -v -w cat | grep STAT_CHECK | awk -F '"' '{print $2}' | awk '{print length}'| sort | tail -n+15)


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