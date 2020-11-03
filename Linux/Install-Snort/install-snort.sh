#!/bin/bash

#This script installs Snort and does initial configuration
#Please run this as sudo

#Install pre requisites
apt-get install flex -y
apt-get install bison -y
apt-get install build-essential -y 
apt-get install checkinstall -y
apt-get install libpcap-dev -y
apt-get install libnet1-dev -y
apt-get install libpcre3-dev -y
apt-get install libnetfilter-queue-dev -y
apt-get install iptables-dev -y
apt-get install libdumbnet-dev -y
apt-get install zlib1g-dev -y

#Adds Snort group
groupadd snort
useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort

#Create necessary files and directories
#Snort source files
mkdir /usr/src/snort_src

#Rule files
mkdir /etc/snort
mkdir /etc/snort/rules
mkdir /etc/snort/preproc_rules
mkdir /usr/local/lib/snort_dynamicrules
touch /etc/snort/rules/white_list.rules 
touch /etc/snort/rules/black_list.rules
touch /etc/snort/rules/local.rules

#Log directory
mkdir /var/log/snort

#Setting permissions of directories
chmod -R 5775 /etc/snort
chmod -R 5775 /var/log/snort
chmod -R 5775 /usr/local/lib/snort_dynamicrules
chown -R snort:snort /etc/snort
chown -R snort:snort /var/log/snort
chown -R snort:snort /usr/local/lib/snort_dynamicrules

#Install DAQ
cd /usr/src/snort_src
wget 'https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz'
tar xvfz daq-2.0.6.tar.gz
cd daq-2.0.6
./configure
make
make install

#Install Snort
cd /usr/src/snort_src
wget 'https://www.snort.org/downloads/snort/snort-2.9.11.1.tar.gz'
tar xvfz snort-2.9.11.1.tar.gz
cd snort-2.9.11.1
./configure
make
make install

#Update libraries
ldconfig

#Setup config files
cp /usr/src/snort_src/snort*/etc/*.conf* /etc/snort
cp /usr/src/snort_src/snort*/etc/*.map /etc/snort

#Backup main config file
cp /etc/snort/snort.conf{,.backup}

#Changes configuration with appropiate IP
echo "What is your IP?"
read IP

#Replaces IP in configuration
sed -i "s/HOME_NET any/HOME_NET $IP/1" /etc/snort/snort.conf

#Replaces path files
sed -i 's?var RULE_PATH ..*?var RULE_PATH /etc/snort/rules?' /etc/snort/snort.conf
sed -i 's?var SO_RULE_PATH ..*?var SO_RULE_PATH /etc/snort/so_rules?' /etc/snort/snort.conf
sed -i 's?var PREPROC_RULE_PATH ..*?var PREPROC_RULE_PATH /etc/snort/preproc_rules?' /etc/snort/snort.conf
sed -i 's?var WHITE_LIST_PATH ..*?var WHITE_LIST_PATH /etc/snort/rules?' /etc/snort/snort.conf
sed -i 's?var BLACK_LIST_PATH ..*?var BLACK_LIST_PATH /etc/snort/rules?' /etc/snort/snort.conf

#Comments out unecessary rule paths
sed -i 's?include $RULE_PATH/[^l].*?''?' /etc/snort/snort.conf

#Verifies configuration
snort -T -c /etc/snort/snort.conf

