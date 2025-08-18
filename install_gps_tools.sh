#!/bin/bash
set -e

echo "=== Raspberry Pi GPS Tools ==="

file_location=/home/pi/gps_server/templates/index.html

# --- Install required packages ---
sudo apt update && sudo apt upgrade -y
sudo apt install -y vim gpsd gpsd-clients python3-gps
pip3 install flask gps3 --break-system-packages

sudo apt autoremove -y
sudo systemctl restart gpsd

#sudo nano /etc/default/gpsd
#START_DAEMON="true"
#DEVICES="/dev/ttyACM0"     # or /dev/serial0 for UART GPS
#GPSD_OPTIONS="-n"

# cgps -s 
#
#
#

echo "=== Bootstrap complete ==="

