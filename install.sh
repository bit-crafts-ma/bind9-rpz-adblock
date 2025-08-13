#!/bin/bash

ZONES_DIRECTORY="/etc/bind/zones"
OPT_DIRECTORY="/opt/bind9-rpz-adblock"
LOG_DIRECTORY="/var/log/named"

if [ ! -d "$ZONES_DIRECTORY" ]; then
  sudo mkdir -p "$ZONES_DIRECTORY"
fi
if [ ! -d "$OPT_DIRECTORY" ]; then
  sudo mkdir -p "$OPT_DIRECTORY"
fi

if [ ! -d "$LOG_DIRECTORY" ]; then
  sudo mkdir -p "$LOG_DIRECTORY"
fi

if [ ! -f "$LOG_DIRECTORY/cron.log" ]; then
  sudo touch "$LOG_DIRECTORY/cron.log"
fi

if [ ! -f "/etc/sudoers.d/bind" ]; then
  sudo cp ./bind /etc/sudoers.d/bind
fi

sudo cp ./blocklist-urls.txt  "$OPT_DIRECTORY"
sudo cp ./bind9-rpz-adblock.sh "$OPT_DIRECTORY"
sudo chmod +x  "$OPT_DIRECTORY/bind9-rpz-adblock.sh"
sudo chown -R bind:bind "$ZONES_DIRECTORY"
sudo chown -R bind:bind "$OPT_DIRECTORY"
sudo chown -R bind:bind "$LOG_DIRECTORY"
sudo crontab -u bind cronfile
echo 'Current bind crontab content'
sudo crontab -u bind -l
