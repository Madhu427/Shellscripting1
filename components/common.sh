STAT_CHECK() {

if [ $1 -ne 0 ]; then
  echo -e "\e[1m${2} - /e[1;31mFailed\e[0m"
  exit
else
  echo -e "\e[1m${2} - \e[1;32mSuccess\e[0m"
fi
}
