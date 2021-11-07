#!/bin/bash

function spacer
{
	echo -e "\n=================================================\n"
}

function header
{
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

function menu
{
	echo Menu
	echo -e "\t1) Perform a backup"
	echo -e "\t2) Program a backup with cron "
	echo -e "\t3) Restore the content of a backup "
	echo -e "\t4) Exit\n"

	read -p "Option >> " option
	if [ $option -le 4 -a $option -ge 1 ]
	then
		return $option
	else
		while [ $option -lt 1 -o $option -gt 4 ]
		do
			read -p "Please introduce a valid option [1-4] >> " option
		done
		return $option
	fi
}

function backup
{
  clear
  echo -e "Backup tool\n"
  read -p "Path of the directory >> " path

  if [ -d "$path" ]
  then
    echo -e "\nWe will do a backup of the directory $path"
    read -p "Do yo want to proceed(y/n)? >> " option
    if [ $option = "y" -o $option = "Y" -o $option = "yes" -o $option = "Yes" -o $option = "YES" ]
    then
      if [ ! -d "/backups" ]
      then
         sudo mkdir /backups #This will raise an error if we don't have permissions
         sudo chmod 766 /backups
      fi
      file=$(basename "$path")
      if [ -f /backups/$file*.tar.gz ]
      then
        find /backups -name "$file*.tar.gz" -delete
      fi
      name="$file$(date +%Y%m%d-%H%M)"
      tar -czf "/backups/$name.tar.gz" "$path"
      echo -e "\nThe file $path has been backed up"
      echo -e "Taking you to the main menu"
      sleep 3
      clear
      main
    elif [ $option = "n" -o $option = "N" -o $option = "No" -o $option = "NO" -o $option = "no" ]
    then
      clear
      main
    else
      echo "ERROR -- Invalid option, you'll be redirected to the main menu"
      sleep 2
      main
    fi
  else
    echo "The specified path doesn't exit"
    sleep 2
    clear
    backup
  fi
}

function cronBackup
{
  clear
  echo cron
}

function restoreBackup
{
  clear
  echo -e "Restore backups tool\n"
  echo "List of existing backups: "
  ls /backups
  read -p "Which one do you want to recover >> " answer
  if [ ! -f "$answer" ]
  then
    echo "Introduce a valid option"
    sleep 2
    clear
    restoreBackup
  fi
}

function main
{
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
echo "$(pwd)"
main
exit 0
