#!/bin/sh

#Check whether the input is correct or not
validate_input () {
  if [ -z $1 ]
  then
    interval="30m"
  else
    interval=$1
  fi

  if [ -z $2 ]
  then
    current_dir="/var/tmp/"
  else
    current_dir=$2
  fi

  return 1
}

interval=""

validate_input $1 $2

if [ $? -eq 1 ]
then
  gateway_alive=1

  while [ $gateway_alive -eq 1 ]
  do
    now=$(date +"%Y_%m_%d_%H:%m:%S")
    watchdog_log_file=$current_dir"watchdog_"$now".log"

    nmap -sP -PS21,22,3389 192.168.1.1/24 >> $watchdog_log_file

    sleep $interval

    ping -c5 192.168.1.1 > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      gateaway_alive=0
    fi
  done
else
  echo "Usage: watchdog.sh interval [logDir]\n"
  echo "Example: watchdog.sh 20m /var/tmp/\n"
fi

exit
