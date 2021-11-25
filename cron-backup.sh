#!/bin/bash

workdir="$1/backups"

function main() {
    if [ "$1" != "$(dirname $0)" ]; then
        echo -e "$(date +%Y%m%d-%H%M)\tERROR\tRuntime error, cron-backup.sh must be located in the same directory as backup.sh" >> "$workdir/backup.log"
        exit 1
    else
      name="$workdir/$(basename "$2")-$(date +%Y%m%d-%H%M).tar.gz"
      tar -czf "$name" "$2"
      echo -e "$(date +%Y%m%d-%H%M)\tINFO\tA backup of the directory $2 has been done by cron-backup.sh" >> "$workdir/backup.log"
      echo -e "$(date +%Y%m%d-%H%M)\tINFO\tThe file generated is $(basename "$2").tar.gz and occupies $(du "$name" | cut -f 1) bytes" >> "$workdir/backup.log"
    fi
}

if [ $# -ne 2 ]; then
  echo -e "$(date +%Y%m%d-%H%M)\tERROR\tInvalid number of arguments for cron-backup.sh" >> "$workdir/backup.log"
  exit 1
else
  main $1 $2 2>> "$workdir/backup.log"
  exit 0
fi