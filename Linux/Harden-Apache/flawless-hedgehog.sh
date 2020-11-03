#!/usr/bin/env bash

if [ $(id -u) != '0' ]
then
	echo "You should execute me as root, or better, with sudo."
	exit 1
fi

clear
echo "Get more info at https://github.com/Natsec/flawless-hedgehog"

if [ $# -eq 1 ]
then
	config=$1
else
	config=/etc/apache2/apache2.conf && echo "[info] No parameter given, configuration file assumed to be $config"
fi

backup=${config}.before_launching_flawless-hedgehog
cp $config $backup && echo -e "[info] Making a backup of your configuration file as  -->   ${backup}\n"
echo -e "\n# Security directives added by flawless-hedgehog.sh on $(date)" >> $config


echo '          .:::::::::.   '
echo '         :::::::::::::  '
echo '        /. `::::::::::: '
echo '       o__,_::::::::::° '


echo -e "\n\n Information leakage"
echo "##################################################"

# hide server signature
read -p $'\n'"Disable server signature on error pages ? (y/n):" ans
while [ "$ans" != 'y' ] && [ "$ans" != 'n' ]
do
	read -p $'\n'"Disable server signature on error pages ? (y/n):" ans
done
if [ "$ans" == 'y' ]
then
	echo 'ServerSignature Off' >> $config && echo "Disabling server signature on error pages: Directive 'ServerSignature' set to off."
fi

# hide version in HTTP header
read -p $'\n'"Hide Apache version in HTTP response header ? (y/n):" ans
while [ "$ans" != 'y' ] && [ "$ans" != 'n' ]
do
	read -p $'\n'"Hide Apache version in HTTP response header ? (y/n):" ans
done
if [ "$ans" == 'y' ]
then
	echo 'ServerTokens Prod' >> $config && echo "Hidding Apache version in HTTP response header: Directive 'ServerTokens' set to Production mode."
fi

# disable etag header
read -p $'\n'"Disable Etag header ? (a remote attacker could obtain informations on your system) (y/n):" ans
while [ "$ans" != 'y' ] && [ "$ans" != 'n' ]
do
	read -p $'\n'"Disable Etag header ? (a remote attacker could obtain informations on your system) (y/n):" ans
done
if [ "$ans" == 'y' ]
then
	echo 'FileETag None' >> $config && echo "Disabling Etag response header: Directive 'FileETag' set to None."
fi


echo -e "\n\n Exploration"
echo "##################################################"

# disable directory listing
read -p $'\n'"Disable directory listing ? (y/n):" ans
while [ "$ans" != 'y' ] && [ "$ans" != 'n' ]
do
	read -p $'\n'"Disable directory listing ? (y/n):" ans
done
if [ "$ans" == 'y' ]
then
	sed -i 's/ Indexes//g' $config && echo "Disabling directory listing: Removed parameter 'Indexes' from directive 'Options' for all directories."
	echo "# removed parameter 'Indexes' from directive 'Options' for all directories" >> $config
fi


echo -e "\n\n Authentication bypass"
echo "##################################################"

# restrict method to get post head
read -p $'\n'"Restrict HTTP methods to GET, POST and HEAD ? (protect you from verb tampering attack if you plan to set basic authentication on your server later) (y/n):" ans
while [ "$ans" != 'y' ] && [ "$ans" != 'n' ]
do
	read -p $'\n'"Restrict HTTP methods to GET, POST and HEAD ? (protect you from verb tampering attack if you plan to set basic authentication on your server later) (y/n):" ans
done
if [ "$ans" == 'y' ]
then
	sed -i 's@<Directory /var/www/>@<Directory /var/www/>\n\t<LimitExcept GET POST HEAD>\n\t\tdeny from all\n\t</LimitExcept>@g' $config && echo "HTTP method restricted to GET, POST and HEAD."
	echo "# http method restricted to GET, POST and HEAD for directory /var/www" >> $config
fi


echo -e "\n\n XSS, XST, Clickjacking"
echo "##################################################"

# set cookie with HttpOnly and Secure flag
read -p $'\n'"Set cookie with HttpOnly and Secure flag ? (y/n):" ans
while [ "$ans" != 'y' ] && [ "$ans" != 'n' ]
do
	read -p $'\n'"Set cookie with HttpOnly and Secure flag ? (y/n):" ans
done
if [ "$ans" == 'y' ]
then
	a2enmod headers
	echo 'Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure' >> $config && echo "Added 'HttpOnly' and 'Secure' flag to cookies emitted by the server."
fi

# add header X-XSS-Protection
read -p $'\n'"Add header X-XSS-Protection ? (y/n):" ans
while [ "$ans" != 'y' ] && [ "$ans" != 'n' ]
do
	read -p $'\n'"Add header X-XSS-Protection ? (y/n):" ans
done
if [ "$ans" == 'y' ]
then
	a2enmod headers
	echo 'Header set X-XSS-Protection "1; mode=block"' >> $config && echo "Added X-XSS-Protection header."
fi

# disable trace method
read -p $'\n'"Disable TRACE method ? (y/n):" ans
while [ "$ans" != 'y' ] && [ "$ans" != 'n' ]
do
	read -p $'\n'"Disable TRACE method ? (y/n):" ans
done
if [ "$ans" == 'y' ]
then
	echo 'TraceEnable off' >> $config && echo "Disabling TRACE method: Directive 'TraceEnable' set to off."
fi

# enable X-Frame-Options header
read -p $'\n'"Enable X-Frame-Options header ? (y/n):" ans
while [ "$ans" != 'y' ] && [ "$ans" != 'n' ]
do
	read -p $'\n'"Enable X-Frame-Options header ? (y/n):" ans
done
if [ "$ans" == 'y' ]
then
	a2enmod headers
	echo 'Header always append X-Frame-Options SAMEORIGIN' >> $config && echo "Enabling X-Frame-Options header: header value set to 'SAMEORIGIN'."
fi


echo -e "\n\n DDoS (Slowloris)"
echo "##################################################"

# decrease timeout value from 300 to 40
read -p $'\n'"Decrease the value of 'Timeout' directive from 300 to 40 ? (y/n):" ans
while [ "$ans" != 'y' ] && [ "$ans" != 'n' ]
do
	read -p $'\n'"Decrease the value of 'Timeout' directive from 300 to 40 ? (y/n):" ans
done
if [ "$ans" == 'y' ]
then
	sed -i 's@^\(Timeout\) 300@\1 40@g' $config && echo "Changed 'Timeout' value to 40."
	echo "# changed 'Timeout' value to 40 (default was 300)" >> $config
fi






echo -e "\n[info] Restarting Apache server ...\n"
service apache2 restart
service apache2 status

clear
echo -e "Little hedgehog fluffed his spikes, your Apache configuration now has a first minimal layer of security !\n"

echo '          ./////////.   '
echo '         /////////////  '
echo '        /. `/////////// '
echo '       o__,_//////////° '

echo -e "\nIf you feel like I messed up your configuration, don't panic and run :\nsudo cp $backup $config"
echo -e "\nRegards (^~^)"
