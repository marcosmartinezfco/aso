#!/bin/bash

#made for aso

filedir="$(pwd)"
workdir="$filedir/backups"

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
    return 5 #This way the default option in main will be executed in case of an invalid option
  fi
}

function backup() {
  clear
  echo -e "Backup tool\n"
  read -p "Path of the directory >> " path

  if [ -d "$path" ]; then
    echo -e "\nWe will do a backup of the directory $path"
    read -p "Do yo want to proceed (y/n)? >> " option
    if [ $option = "y" -o $option = "Y" -o $option = "yes" -o $option = "Yes" -o $option = "YES" ]; then
      name="$(basename "$path")-$(date +%Y%m%d-%H%M)"
      tar -czf "$workdir/$name.tar.gz" "$path"
      echo -e "\nThe directory $path has been backed up"
      echo -e "$(date +%Y%m%d-%H%M)\tINFO\tThe directory $path has been backed up" >> "$workdir/backup.log"
      echo -e "Taking you to the main menu"
    elif [ $option = "n" -o $option = "N" -o $option = "No" -o $option = "NO" -o $option = "no" ]; then
      echo -e "\nOkay, you'll be redirected to the main menu"
    else
      echo -e "\nInvalid option, you'll be redirected to the main menu"
      echo -e "$(date +%Y%m%d-%H%M)\tERROR\tInvalid option in the backup tool menu" >> "$workdir/backup.log"
    fi
  else
    echo -e "\nThe specified path doesn't exit, taking you to the main menu"
    echo -e "$(date +%Y%m%d-%H%M)\tERROR\tInvalid path specified in the backup tool menu" >> "$workdir/backup.log"
  fi
  sleep 2
  clear
  main
}

function cronBackup() {
  clear
  echo -e "Program backups tool\n"
  read -p "Absolute path to the directory >> " path
  if [ -d "$path" -a "$(echo "$path" | cut -c 1)" == "/" ]; then
    read -p "Hour of the backup (0:00 - 23:59) >> " time
    if [[ "$time" =~ ^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$ ]]; then
      read -p "The backup will execute at $time. Do you agree? (y/n) >> " option
      if [ $option = "y" -o $option = "Y" -o $option = "yes" -o $option = "Yes" -o $option = "YES" ]; then
        hour=$(echo "$time" | cut -d : -f 1)
        min=$(echo "$time" | cut -d : -f 2)
        crontab -l > /tmp/crontabaso
        echo "$min $hour * * 1-7 $filedir/cron-backup.sh $filedir $path" >> /tmp/crontabaso
        crontab /tmp/crontabaso
        echo "Task added to crontab file, taking you to the main menu"
        echo -e "$(date +%Y%m%d-%H%M)\tINFO\tTask added to crontab file" >> "$workdir/backup.log"
      else
        echo -e "\nOkay, you'll be redirected to the main menu"
      fi
    else
      echo -e "\nInvalid hour format, you'll be redirected to the main menu"
      echo -e "$(date +%Y%m%d-%H%M)\tERROR\tInvalid hour format in the cron backup tool" >> "$workdir/backup.log"
    fi
  else
    echo -e "\nInvalid path, you'll be redirected to the main menu"
    echo -e "$(date +%Y%m%d-%H%M)\tERROR\tInvalid path selected in the cron backup tool" >> "$workdir/backup.log"
  fi
  sleep 2
  clear
  main
}

function restoreBackup() {
  clear
  echo -e "Restore backups tool\n"
  echo -e "List of existing backups:\n"
  for file in $workdir/*.tar.gz; do
    if [ $file != "$workdir/*.tar.gz"  ]; then
        echo -e "\t+ $(basename "$file")"
    fi
  done
  echo " "
  read -p "Which one do you want to recover >> " answer
  if [ -f "$workdir/$answer" ]; then
    echo "Restoring $answer ..."
    echo -e "$(date +%Y%m%d-%H%M)\tINFO\tRestoring backup file $answer" >> "$workdir/backup.log"
    tar -xf "$workdir/$answer"
  else
    echo "There is no such file, taking you to the main menu"
    echo -e "$(date +%Y%m%d-%H%M)\tERROR\tInvalid bakup file selected in the restore backup tool" >> "$workdir/backup.log"
  fi
  sleep 2
  clear
  main
}

function main() {
  if [ ! -d $workdir ]; then
    mkdir $workdir
    chmod 766 $workdir
  fi
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
  *)
    clear
    header
    main
    ;;
  esac
}

header
main
exit 0
