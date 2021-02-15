You may want to pull up a Linux Command Line Cheatsheet 

[Windows and Linux
Terminals & Command Lines](https://assets.contentstack.io/v3/assets/blt36c2e63521272fdc/bltea7de5267932e94b/5eb08aafcf88d36e47cf0644/Cheatsheet_SEC301-401_R7.pdf)

[Linux 101 Command Line Cheat Sheet](https://wiki.sans.blue/Tools/pdfs/LinuxCLI101.pdf)

[Linux Command Line Cheat Sheet](https://wiki.sans.blue/Tools/pdfs/LinuxCLI.pdf)

## Task 1. Prepare JumpBox  

```
ssh -MS /tmp/night1 -p 22 root@remote_box_ip_goes_here
```

## **Tasks 2 to 4 are scripted [here](https://github.com/WGU-CCDC/Blue-Team-Tools/blob/master/Linux/CCDCprep/Checklist/Automation/lockdown.sh) and should be tried first.**

To run the script, copy and paste it into a .sh file.

```
nano lockdown.sh
sudo chmod +x lockdown.sh
sudo ./lockdown.sh OR sudo bash -v lockdown.sh
```
Skip to Task 5 [here](https://github.com/WGU-CCDC/Blue-Team-Tools/tree/master/Linux/CCDCprep/Checklist#Task_5)

## Task 2.  Create Backup Admins 

    Step 1: 
 
    adduser --disabled-password --gecos "" nightowl
    
    Step 2: 
    
    usermod -aG sudo nightowl 
   
    Step 3: 
   
    adduser --disabled-password --gecos "" nightowl2
   
    Step 4: 
   
    usermod -aG sudo nightowl2
   
    Step 5: Notify team of usernames and passwords.







## Task 3. Get a list of all users
    
   
    cat /etc/passwd | cut -d: -f1 > user_list.txt
    


## Task 4. Change the passwords for all users  
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







## Task 5. Copy password and enumeration files to the JumpBox
<a name="Task_5"></a>

On the JumpBox

NOTE: **DO NOT** replace remoteip with the ip address, since we already have a socket open this will work as is.

```
scp -o controlpath=/tmp/night1 root@remoteip:/path/to/sysinfo.txt

scp -o controlpath=/tmp/night1 root@remoteip:/path/to/userlist.txt
```

## Shred password and Enumeration files on the RemoteBox
After Running the script and downloading the files to your JumpBox, it's important to securely remove the passwords and anything else from the directory that could help the redteam.

On the RemoteBox
```
shred -z sysinfo.txt

shred -z userlist.txt
```


## Task 6. List and Disable Non Business required services.

We should find out about our network 30 minutes beforehand, so mapping business requirements to services should already be done. If not do it now.

Start with a nmap scan of the host.

```
nmap box_ip_goes_here
```
We can also use
```
service --status-all
systemctl list-units
chkconfig --list
systemctl --type=service
```

Make a list of open ports/servicenames and compare it to business requirements.
If we do not recognize a service or port, make a note and look it up, if it is a business requirement make note of it and put it in a list with the other business required services.

Once we have our list of required services, it should be easy to have a list of unneeded services. Instead of blocking the port on the firewall, we will be stopping the services.

We can use
```
ps aux | grep service_goes_here
```

to find where it's running, since service doesn't always match the service_name

for example ftp but the service_name is vsftpd

Next you will need to Disable or Uninstall the unneeded services

## Disable Non Business Required Services

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
## Uninstall if you know it will not be needed again, otherwise just leave it stopped and disabled across reboots.
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

## Check to see if the service is actually stopped.
nmap the box again to check if the service has actually stopped, then rinse and repeat.

```
nmap box_ip_goes_here
```

## Task 7. Check the business required services for admin panels and default passwords. Check the service version and update.

Now that we have a list of services, we can google them.

We need to find out:

1. Are there any default credentials associated with the service and how do we change them?
2. Where are the configuration files for the service stored?
3. Is the version of the service we are running vulnerable and can we update it?
4. Where does the service output log files and how do we configure where the log files go?

Once we have that information, we should:

1. Change the default passwords and turn off any anonymous logins or default credentials.
2. Check the configuration files for anything we might have missed in documentation.
3. Update the service where possible.
4. Make note of where the service outputs logs so we can monitor them for potential indicators that something is wrong. If there are no logs by default try and turn some on.
5. SCP a copy of the log files to our JumpBox so we can see if they have been altered later.


