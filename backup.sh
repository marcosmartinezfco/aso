#!/bin/bash

workdir="/home/$(whoami)/backups"

function spacer() {
  echo -e "\n=================================================\n"
}

function header() {
  echo " ____             _    _   _            _     "
  echo "| __ )  __ _  ___| | _| | | |_ __   ___| |__  "
  echo "|  _ \ / _\` |/ __| |/ / | | | '_ \ / __| '_ \ "
  echo "| |_) | (_| | (__|   <| |_| | |_) |\__ \ | | |"
  echo "|____/ \__,_|\___|_|\_\\___/| .__(_)___/_| |_|"
  echo "                            |_|               "
  echo -e "\nASO 2021-2022"
  echo -e "Marcos Martinez Francisco"
  spacer
}

function redicrect() {
  sleep 2
  clear
  main
}

function menu() {
  echo Menu
  echo -e "\t1) Perform a backup"
  echo -e "\t2) Program a backup with cron "
  echo -e "\t3) Restore the content of a backup "
  echo -e "\t4) Exit\n"

  read -p "Option >> " option
  if [ $option -le 4 -a $option -ge 1 ]; then
    return $option
  else
    while [ $option -lt 1 -o $option -gt 4 ]; do
      read -p "Please introduce a valid option [1-4] >> " option
    done
    return $option
  fi
}

function backup() {
  clear
  echo -e "Backup tool\n"
  read -p "Path of the directory >> " path

  if [ -d "$path" -o -f "$path" ]; then
    echo -e "\nWe will do a backup of the directory $path"
    read -p "Do yo want to proceed (y/n)? >> " option
    if [ $option = "y" -o $option = "Y" -o $option = "yes" -o $option = "Yes" -o $option = "YES" ]; then
      if [ ! -d $workdir ]; then
        mkdir $workdir
        chmod 766 $workdir
      fi
      file=$(basename "$path")
      for x in $workdir/$file*.tar.gz; do
        rm $x
      done
      name="$(basename "$path")-$(date +%Y%m%d-%H%M)"
      tar -czf "$workdir/$name.tar.gz" "$path"
      echo -e "\nThe file $path has been backed up"
      echo -e "Taking you to the main menu"
      redirect
    elif [ $option = "n" -o $option = "N" -o $option = "No" -o $option = "NO" -o $option = "no" ]; then
      clear
      main
    else
      echo "ERROR -- Invalid option, you'll be redirected to the main menu"
      redicrect
    fi
  else
    echo "The specified path doesn't exit"
    sleep 2
    clear
    backup
  fi
}

function cronBackup() {
  clear
  echo -e "Program backups tool\n"
  read -p "Absolute path to the file >> " path
  if [ -d "$path" -o -f "$path" ]; then
    read -p "Hour of the backup (0:00 - 23:59) >> " time
    read -o "The backup will execute at $time. Do you agree? (y/n) >> "
    if [ $option = "y" -o $option = "Y" -o $option = "yes" -o $option = "Yes" -o $option = "YES" ]; then
      hour=$(echo $time | cut -d : -f 1)
      min=$(echo $time | cut -d : -f 2)
      if [ $hour -le 23 -a $hour -ge 0 -a $min -le 59 -a $min -ge 00 ]; then
        crontab -l >/tmp/crontabaso
        echo "$min $hour * * 1-7 tar -czf $workdir/$(basename "$path")-$(date +%Y%m%d-%H%M).tar.gz $path" >>/tmp/crontabaso
        crontab /tmp/crontabaso
        redirect
      else
        echo -e "\nERROR -- Invalid hour format, you'll be redirected to the main menu"
        redirect
      fi
    else
      echo -e "\nOkay, you'll be redirected to the main menu"
      redirect
    fi
  else
    echo -e "\nERROR -- Invalid path, you'll be redirected to the main menu"
    sleep 2
    clear
    main
  fi

}

function restoreBackup() {
  clear
  echo -e "Restore backups tool\n"
  echo "List of existing backups: "
  for file in $workdir/*; do
    echo -e "\t+ $(basename "$file")"
  done
  echo " "
  read -p "Which one do you want to recover >> " answer
  if [ -f "$workdir/$answer" ]; then
    echo -e "\nRestoring $answer ..."
    tar -xf "$workdir/$answer"
  else
    echo "There is no such file, taking you to the main menu"
    redirect
  fi
}

function main() {
  menu
  case "$?" in
  1)
    backup
    ;;
  2)
    cronBackup
    ;;
  3)
    restoreBackup
    ;;
  4)
    echo -e "\nBye, Bye"
    exit 0
    ;;
  esac
}

header
main
exit 0
