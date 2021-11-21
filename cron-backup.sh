#!/bin/bash

workdir="/home/$(whoami)/backups"

if [ ! -f "$(pwd)/backup.sh" ]; then
    echo -e "$(date +%Y%m%d-%H%M)\tERROR\tRuntime error, cron-backup.sh must be located in the same directory as backup.sh" >> "$workdir/backup.log"
    exit 1
elif [ $# -ne 1 ]; then
    echo -e "$(date +%Y%m%d-%H%M)\tERROR\tInvalid number of arguments for cron-backup.sh" >> "$workdir/backup.log"
    exit 1
else
  name="$workdir/$(basename "$1")-$(date +%Y%m%d-%H%M).tar.gz"
  tar -czf "$name" "$1"
  echo -e "$(date +%Y%m%d-%H%M)\tINFO\tA backup of the directory $1 has been done by cron-backup.sh" >> "$workdir/backup.log"
  echo -e "$(date +%Y%m%d-%H%M)\tINFO\tThe file generated is $(basename "$1").tar.gz and occupies $(du "$name") bytes" >> "$workdir/backup.log"
fi