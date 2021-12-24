USER_UID=$(id -u)

if [ ${USER_UID} -ne 0 ]; then

  echo -e "\e[1;31m You should be root user to perform the script \e[0m"
  exit
fi

export COMPONENT=$1

if [ -z "$COMPONENT" ]; then
  echo -e "\e[1;31m Component is missing\e[0m"
  exit
fi

if [ ! -e components/${COMPONENT}.sh ]; then
  echo -e "\e[1;31mGiven Component doesn't exist in the Script\e[0m"
  exit
fi

bash components/${COMPONENT}.sh