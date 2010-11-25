#!/bin/bash


has=$(cat ~/.bashrc | egrep "^# ADDED BY npm FOR NVM$" || true)
if [ "x$has" == "x" ]; then
  echo "doesn't have it, exiting"
  exit 0
fi
tmp=~/.bashrc.tmp
cat ~/.bashrc | {
  incode=0
  while read line; do
    if [ "$line" == "# ADDED BY npm FOR NVM" ]; then
      incode=1
    elif [ "$line" == "# END ADDED BY npm FOR NVM" ] \
          && [ $incode -eq 1 ]; then
      incode=0
    elif [ $incode -eq 0 ]; then
      echo "$line" >> $tmp
    fi
  done
}
mv $tmp ~/.bashrc
