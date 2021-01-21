



WGU CCDC Basic *Nix Checklist / First Fifteen Minutes guidelines

Notes:
Run these commands to help gather this information
```
uname -a
lscpu
lsblk,etc
ip a, ifconfig, iwconfig
```





NOTE: Steps 1 to 3 are scripted [here](https://github.com/WGU-CCDC/Blue-Team-Tools/blob/master/Linux/CCDCprep/Checklist/Automation/lockdown.sh) and should be tried first.

## Task 1.  Create Backup Admins 

    Step 1: 
    ```
    adduser --disabled-password --gecos "" nightowl
    ```
    Step 2: 
    ```
    usermod -aG sudo nightowl 
    ```
    Step 3: 
    ```
    adduser --disabled-password --gecos "" nightowl2
    ```
    Step 4: 
    ```
    usermod -aG sudo nightowl2
    ```
    Step 5: Notify team of usernames and passwords.







## Task 2. Get a list of all users
    
    ```
    cat /etc/passwd | cut -d: -f1 > user_list.txt
    ```


## Task 3. Change the passwords for all users  
IMPORTANT: Notify Team via team comms on password changes  

Simple Bash Script to loop through users and change password
```
#!/bin/bash
for i in `cat user_list.txt`
do
PASS=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 31)
echo "Changing password for $i" 
echo "$i,$PASS" >>  userlist.txt
echo -e "$PASS\n$PASS" | passwd $i
done
```

**OR**
 
 
Step 1: 
Create a username password list separated by a 
colon using the username list from your previous task : Example username:newpassword (Each pair should be on a new line.)
Copy this list to your clipboard.

Step 2: 
Enter the chpasswd command in the terminal
```
chpasswd
```
Step 3: 
Now that the command is running, paste in a prepared list of usernames and passwords by right clicking on the terminal and selecting paste or the key combo of Ctrl+Shift+v

Step 4: 
Enter Ctrl +D to exit when done 

If chpasswd doesn’t work or to change an individual password:
Use the command 
```
passwd username 
```
**OR** simply 
```
passwd
```
to change the current user's password 

Step 5: 
Notify the rest of the team of password changes and put it into a report format when you have time since you will need to inform management of any password changes for users.

 

 
 
Subtask (can be performed simultaneously)
Step 1. Install fail2ban with default settings.
 
```
apt install fail2ban 
```

OR
```
yum install fail2ban 
```
 
Step 2. Check that fail2ban is running
```
  service fail2ban status
```

 
3b


See Appendix
 
 
 





## Task 4. Close unneeded ports on the firewall
Step 1: Identify open ports via one of the following commands:

```
sudo netstat -tulpn | grep LISTEN 
ss -tulwn | grep LISTEN
netstat -tulpn 
ss -ltup 
sudo nmap -sTU -O localhost -> requires nmap installed 
```

Step 2: Using the following sections for the firewall that is installed
i. View current rules
ii. Add rules for TCP and UDP to block unneeded ports
iii. Reload the firewall
iv. View the current rules again to make sure the rules were applied
Step 3: Document ports that were blocked.
 
IPTABLES  
 
Disabling other firewalls (not recommended -> just use the other firewall if you have it.) 
```
systemctl disable --now ufw 
systemctl disable --now firewalld 
```

View current rules 
```
iptables -S -v 
Iptables -L -v 
```
Flush Current Firewall rules
```
sudo iptables -F
``` 
Add a rule for a specific port ( example HTTPS) (each line must be added one at a time)   
```
iptables –A INPUT –p udp --dport 443 –j ACCEPT 
iptables –A INPUT –p tcp --dport 443 –j ACCEPT 
iptables –A OUTPUT –p udp --dport 443 –j ACCEPT 
iptables –A OUTPUT –p tcp --dport 443 –j ACCEPT 
``` 
Block a specific port (example HTTPS) (each line must be added one at a time) 
Add a rule for a specific port ( example HTTPS) 
```
iptables –A INPUT –p udp --dport 443 –j DROP 
iptables –A INPUT –p tcp --dport 443 –j DROP 
iptables –A OUTPUT –p udp --dport 443 –j DROP 
iptables –A OUTPUT –p tcp --dport 443 –j DROP
```

Enable iptables logging (each line must be added one at a time) 
```
iptables -N LOGGING 
iptables -A INPUT -j LOGGING 
iptables -A OUTPUT -j LOGGING 
iptables -A FORWARD -j LOGGING 
iptables -A LOGGING -j LOG --log-level error --log-prefix "iptables-dropped: " 
iptables -A LOGGING -j DROP 
``` 
Delete Rules by Specification 
First list rules by specification: 
```
iptables -S 
```
Then use the -D option (for example a previous HTTPS rule) 
```
iptables –D INPUT –p udp --dport 443 -j DROP 
``` 
Save changes to iptables  
 
Ubuntu 
```
sudo /sbin/iptables-save
```
For the changes to last after restarting the service:
```
/sbin/iptables-save > /etc/iptables/rules.v4 
```
CentOS/Red Hat 
```
/sbin/service iptables save 
```
OR 
```
/etc/init.d/iptables save 
```
 
Reload Rules 
```
service iptables restart 
``` 
UFW and Firewalld are built on iptables
 

           
 
## Task 6. Get a list of services and change default passwords/restrict admin panels to localhost
Step 1: Try one of the following to list services
```
service --status-all
systemctl list-units
chkconfig --list
systemctl --type=service
```
Step 2: Lookup and change defaults


Disable or Uninstall  unneeded services

Disable
Step 1: Stop the service
```
service servicename stop
```
OR 
```
systemctl stop servicename
```

Step 2: Disable the service across reboots
```
chkconfig servicename off
```
OR
```
systemctl disable servicename
```
Uninstall
```
apt-get remove service_package_name 
```
OR
```
yum remove service_package_name 
```
OR
```
dnf remove service_package_name 
```



update services
Step 1: Check service version
```
service_name --version
```
OR
```
service_name -version
```
OR
```
service_name -v
```
Step 2: Backup configuration file(s)
Lookup configuration file locations by service version
Then copy the file to a different location and file name
```
cp /path/to/configfile.conf /path/to/backupconfigfile.bak
```

Step 3: Update repositories to make sure you can get the latest version
```
yum -y update
```
OR
```
apt-get update
```
Step 4: Upgrade the service package
```
yum update service_package_name
```
OR
```
apt install service_package_name
```






## Task 7. Patch Kernel
Step 1: Determine current Kernel version
```
uname -a
```
OR
```
cat /etc/os-release
```
Step 2: Update repositories
```
yum -y update
```
OR
```
apt-get update
```
Step 3: Run the upgrade
```
sudo apt-get dist-upgrade
```
Step 4: Make sure ssh and or rdp will start on reboot

i. List the services that run on start
```
sudo service --status-all
```
OR
```
sudo systemctl list-unit-files --type=service
```
ii. Turn on ssh or rdp if it’s off
```
chkconfig servicename on
```
OR
```
systemctl enable servicename
```
Step 5: Reboot the system
sudo reboot
OR
sudo shutdown -r






## Task 8. Install Tools
Tripwire, rkhunter, clamav, inotify-tools

Step 1:
i.
apt -y install tripwire rkhunter clamav inotify-tools
OR
yum -y install tripwire rkhunter clamav inotify-tools

ii. Select yes when/if prompted
iii. Enter passphrases, record them and notify team of changes
iv. Configure programs for use

Tripwire
tripwire --init
tripwire --check
tripwire --check >> tripwire_check.txt

rkhunter
rkhunter -c -sk >> rkhunter_check.txt

clamav
clamscan -r / >> clamav_check.txt

inotify-tools
nano watchme.txt
Enter file locations to watch, one on each line
For example:
.bashrc
.profile
/etc/passwd

CTRL + X and Y to save the file

Step 2: Monitor logs
Each log file should have it’s own terminal per host

Tripwire
tail -f tripwire_check.txt

rkhunter
tail -f rkhunter_check.txt

clamav
tail -f clamav_check.txt

inotify-tools
sudo inotifywait -m --fromfile watchme.txt

MISC
watch w
sudo watch -n 10 lsof -i
tail -f /var/log/auth.log
sudo watch  ss -tulpn















Appendix:
Step 1:

Step 2:
Step 1: Try a command and if it doesn’t work go to the next one.
Try first:
Debian based awk -F: '($3>=1000)&&($1!="nobody"){print $1}' /etc/passwd > user_list.txt
OR 
Centos based awk -F: '($3>=500)&&($1!="nobody"){print $1}'/etc/passwd > user_list.txt

Try second: column -nts: /etc/passwd  
Try third: cat /etc/passwd 
Try fourth: awk -F: '{ print $1}' /etc/passwd > user_list.txt 
Try fifth: compgen -u
Step 2: Document the command output for later use

Step 3:
3b:
Lockout or Remove Non-essential Users  
(Since some users are business essential and may be required for scoring, locking users out will be faster) . 
 
usermod – L username stops an account from logging in. 
OR
deluser --remove-home username OR userdel –remove username will delete a user and their home directory. 

Step 4: 




Step 5:
UFW 
 
VIew current rules 
sudo ufw status 
 
Add a rule for a specific port (example HTTPS) 
sudo ufw allow 443 
 
Block a specific port (example HTTPS) 
sudo ufw deny 443 
 
Delete a rule (example HTTPS) 
sudo ufw status numbered 
sudo ufw delete RuleNumberGoesHere 
 
At the Prompt type y and hit Enter 
 
Reload Rules 
sudo ufw reload 
 
Firewalld 
 
View current rules 
firewall-cmd --list-all 
 
Add a rule for a specific port (example HTTPS) 
firewall-cmd --permanent –add-port=443/TCP 
firewall-cmd –permanent --add-port=443/UDP 
 
Delete a rule (example HTTPS) 
firewall-cmd --permanent –remove-port=443/TCP 
firewall-cmd –permanent --remove-port=443/UDP 
 
Reload Rules 
firewall-cmd --reload  


