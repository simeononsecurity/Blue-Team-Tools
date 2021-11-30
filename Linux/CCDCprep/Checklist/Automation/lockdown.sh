#!/usr/bin/env bash


check_crontab_func (){
for user in $(cut -f1 -d: /etc/passwd); do echo "###### $user crontab is:"; cat /var/spool/cron/{crontabs/$user,$user} 2>/dev/null; done >> sysinfo.txt
}

enumerate_func (){
#enumerate system
date -u  >> sysinfo.txt
uname -a >> sysinfo.txt

# Added in error testing, who knows what gets borked
# per https://www.linux.org/docs/man5/os-release.html
# /usr/lib/os-release should be the fallback

if . /etc/os-release ; then
        OS=$NAME
else
        . /usr/lib/os-release
        OS=$NAME
fi

echo "OS is $ID" >> sysinfo.txt
lscpu    >> sysinfo.txt
lsblk    >> sysinfo.txt
ip a     >> sysinfo.txt
sudo netstat -auntp >>sysinfo.txt
df       >> sysinfo.txt
ls -latr /var/acc >> sysinfo.txt
sudo ls -latr /var/log/* >> sysinfo.txt
sudo ls -la /etc/syslog >> sysinfo.txt
check_crontab_func
cat /etc/crontab >> sysinfo.txt
ls -la /etc/cron.* >> sysinfo.txt
sestatus >> sysinfo.txt
getenforce >> sysinfo.txt
sudo cat /root/.bash_history >> sysinfo.txt
cat ~/.bash_history >> sysinfo.txt
cat /etc/group >> sysinfo.txt
cat /etc/passwd >> sysinfo.txt

# If Debian or Ubuntu (or Arch if we add support), then ufw is installed
# ufw = Uncomplicated Firewall - https://help.ubuntu.com/community/UFW
if [ "$OS" = "Ubuntu" ]; then

ufw-status=$(sudo ufw status)
echo "ufw $ufw-status" >> sysinfo.txt

elif [ "$OS" = "Debian" ]; then

ufw-status=$(sudo ufw status)
echo "ufw $ufw-status" >> sysinfo.txt

fi
}

backup_admin_func (){
#addbackup Admins
adduser --disabled-password --gecos "" nightowl || echo "User Exists"
adduser --disabled-password --gecos "" nightowl2 || echo "User Exists"
usermod -aG sudo nightowl
usermod -aG sudo nightowl2
}

list_users_func (){
    cat /etc/passwd | cut -d: -f1 > user_list.txt
}

change_passwords_func (){
for i in `cat user_list.txt`
do
PASS=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 31)
#PASS=test
echo "Changing password for $i" 
echo "$i,$PASS" >>  userlist.txt
echo -e "$PASS\n$PASS" | passwd $i
done

install_tools_func () {

# Added in error testing, who knows what gets borked
# per https://www.linux.org/docs/man5/os-release.html
# /usr/lib/os-release should be the fallback

if . /etc/os-release ; then
        OS=$NAME
        echo "$OS"
else
        . /usr/lib/os-release
        OS=$NAME
        echo "$OS"

fi

echo "$OS installing tools"

if [ "$OS" = "Ubuntu" ]; then

apt -y install fail2ban tripwire clamav inotify-tools

elif [ "$OS" = "Debian" ]; then

apt -y install fail2ban tripwire clamav inotify-tools

elif [ "$OS" = "CentOS Linux" ];then

yum -y install fail2ban tripwire clamav inotify-tools

else 
echo "Not Ubuntu, Debian or CentOS, install tools manually"

fi
}


}
main_func (){
enumerate_func
backup_admin_func
list_users_func
change_passwords_func
install_tools_func
}

main_func
