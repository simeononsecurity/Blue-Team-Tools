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
}

# Backup, display differences to official repos, and restore (with flag)
# to official repos
# code for check_repositories_func released under GNU GPLv3
check_repositories_func (){

	currDate = $(date)

	# Need to check OS to determine repo types
	# Probably should make this a function at this point
	if . /etc/os-release ; then
                OS=$NAME
        else
                . /usr/lib/os-release
                OS=$NAME
    fi

	if [ "$OS" = "Ubuntu" ]; then
		
		# Backups First with timestamp
		if . /etc/apt/sources.list ; then
			cp /etc/apt/sources.list $(currDate)-sources.list
		else
			echo "[-] /etc/apt/sources.list Not Found!"
			echo "[ ] Attempting to create new source list"
		fi
		# /etc/apt/sources.list.d is a dir, need to check size before copying
		# du, short for disk usage, seems to be a decent way since 4.0K is the size of empty
		
		sourceDirSize=`du -sh /etc/apt/sources.list.d | cut -f1` #removes the tab by default

		if [ "$sourceDirSize" != "4.0K" ]; then
			echo "[ ] Check /etc/apt/sources.list.d for any suspicious sources"
		else
			echo "[+] /etc/apt/sources.list.d not found"
		fi

		# display differences to official repos
		# will need to generate these files on clean installs then
		# upload since no one copy ability exist
		# wget <github raw text file link here>
		#if diff file1 file2 > source.list-Diff.txt ; then
			#echo "[+] Diff completed for file1 to file2
 
		#else
			#echo "[-] Diff failed for file1 to file2"
		#fi

        #elif [ "$OS" = "Debian" ]; then
		#apt -y install fail2ban tripwire clamav inotify-tools

        #elif [ "$OS" = "CentOS Linux" ];then
		#yum -y install fail2ban tripwire clamav inotify-tools

		#else
		#echo "Not Ubuntu, Debian or CentOS, install tools manually"

        #fi
    fi
}

install_tools_func () {

	# Added in error testing, who knows what gets borked
	# per https://www.linux.org/docs/man5/os-release.html
	# /usr/lib/os-release should be the fallback

	if . /etc/os-release ; then
	        OS=$NAME
	else
	        . /usr/lib/os-release
	        OS=$NAME
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


main_func (){
	enumerate_func
	backup_admin_func
	list_users_func
	change_passwords_func
	install_tools_func
}

main_func
