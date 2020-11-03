#!/bin/bash

# Shane Sexton
# May 3, 2016
# SSH Hardening Script
# Version 1.1
#
# This is a script to automate the hardening of SSH servers. It makes
# several common changes to sshd_config to make SSH less vulnerable to
# attackers. It has options to back up sshd_config, update SELinux and
# firewalld rules, and set an SSH banner.
# Syntax: "sudo ssh_harden.sh i" for interactive mode or
# "sudo ssh_harden.sh q" for quick mode

#Check if running with proper privileges
function check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script requires root privileges." 1>&2
    exit 1
  fi
}

#Set initial value for SSHD_CONF_LOC
SSHD_CONF_LOC="/etc/ssh/sshd_config"

#Check if sshd_config is in the right place (keep checking until existing
#file is found)
function sshd_config_check() {	 
  if [[ -f $SSHD_CONF_LOC ]]; then
    echo "sshd_config found"
  else
    echo -n "Unable to find sshd_config. Please specify path: "
    read SSHD_CONF_LOC
    sshd_config_check
  fi
}

#Back up sshd_config to current directory
function backup_sshd_config() {
  cp $SSHD_CONF_LOC .
  echo "Backed up sshd_config to $(pwd)"
}

#Change SSH protocol
function change_protocol() {
  sed -i -e 's/^.*Protocol.*$/Protocol 2/' $SSHD_CONF_LOC
}

#Change PermitRootLogin
function root_login() {
  sed -i -e 's/^.*PermitRootLogin.*$/PermitRootLogin no/' $SSHD_CONF_LOC
}

#Change SSH port
function ssh_port() {
  echo -n "Enter desired port (1-65535): "
  read port_number
  if [ $port_number -gt 0 -a $port_number -lt 65536  ] ; then
    sed -i -e "s/^.*Port.*$/Port $port_number/" $SSHD_CONF_LOC
  else 
    echo "Please specify port number between 1 and 65535."
    ssh_port
  fi  
}

#Change max authentication attempts
function max_auth() {
  echo -n "Enter maximum number of allowed authentication attempts: "
  read auth_attempts
  if [ $auth_attempts -gt 0 -a $auth_attempts -lt 11  ] ; then
    sed -i -e "s/^.*MaxAuthTries.*$/MaxAuthTries $auth_attempts/" $SSHD_CONF_LOC
  else 
    echo "Please specify number between 1 and 10."
    max_auth
  fi  
}

#Disallow empty passwords
function empty_passwords() {
  sed -i -e 's/^.*PermitEmptyPasswords.*$/PermitEmptyPasswords no/' $SSHD_CONF_LOC
}

#Change login gracetime
function login_gt() {
  echo -n "Enter desired gracetime (in seconds): "
  read grace_time
  if [ $grace_time -gt 4 -a $grace_time -lt 121  ] ; then
    sed -i -e "s/^.*LoginGraceTime.*$/LoginGraceTime $grace_time/" $SSHD_CONF_LOC
  else
    echo "Please specify gracetime between 5 and 120"
    login_gt
  fi
}

#Disable password authentication
function disable_pw() {
  sed -i -e 's/^.*PasswordAuthenticat.*$/PasswordAuthentication no/g' $SSHD_CONF_LOC
}

#Disable rhosts
function disable_rhosts() {
  sed -i -e 's/^.*IgnoreRhosts.*$/IgnoreRhosts yes/' $SSHD_CONF_LOC
}

#Set warning banner
function warning_banner() {
  touch /etc/ssh/sshd_banner
  cat >/etc/ssh/sshd_banner <<EOF
   WARNING : Unauthorized access to this system is forbidden and will be
   prosecuted by law. By accessing this system, you agree that your actions
   may be monitored if unauthorized usage is suspected.
EOF
vi /etc/ssh/sshd_banner
sed -i -e 's=^.*Banner.*$=Banner /etc/ssh/sshd_banner=' $SSHD_CONF_LOC
}

#This function updates SELinux to have SSH match the new port number.
#It creates and removes a temporary swap file if there isn't swap space
#(semanage can be unstable otherwise). 
function selinux_update() {	
  if [[ -z "$(swapon -s)" ]] ; then
    echo "No swap space enabled. Making 64mb temporary swap file. "
    echo "(Swap space needed when modifying SELinux)"
    dd if=/dev/zero of=/temp_swapfile1 bs=1024 count=64000
    chown root:root /temp_swapfile1
    chmod 600 /temp_swapfile1
    mkswap /temp_swapfile1
    swapon /temp_swapfile1
  fi
  
  echo "Updating port number with SELinux."
  echo "Port number: $port_number"
  semanage port -a -t ssh_port_t -p tcp $port_number
  
  if [[ -f /temp_swapfile1 ]] ; then
    echo "Removing temporary swap file."
    swapoff /temp_swapfile1
    rm /temp_swapfile1
  fi
}

#Check whether SELinux in Enforcing or Permissive mode
function selinux_check() {
  if [[ "$(getenforce)" == "Enforcing" ]] ; then
    echo "SELinux is installed and running on this system in Enforcing mode."
    echo "You should update SELinux to allow the new port number if you changed it."
    echo -n "Would you like this script to update SELinux? (y/n) "
    read selinux_update_response
    case $selinux_update_response in
      [Yy]|[Yy][Ee][Ss]) selinux_update ;;
      [Nn]|[Nn][Oo]) echo "SELinux unchanged." ;;
      *) echo "Unrecognized command..." ;;
    esac 
  fi

 if [[ "$(getenforce)" == "Permissive" ]] ; then
    echo "SELinux is installed and running on this system in Permissive mode."
    echo "You should update SELinux to allow the new port number if you changed it."
    echo -n "Would you like this script to update SELinux? (y/n) "
    read selinux_update_response
    case $selinux_update_response in
      [Yy]|[Yy][Ee][Ss]) selinux_update ;;
      [Nn]|[Nn][Oo]) echo "SELinux unchanged." ;;
      *) echo "Unrecognized command..." ;;
    esac
  fi
}

function firewalld_update() {
  if [[ "$(firewall-cmd --state)" =~ ^.*not.*$ ]] ; then
    systemctl start firewalld.service 
  fi
  firewall-cmd --permanent --zone=public --add-port=$port_number/tcp
  firewall-cmd --reload
}

#Check whether FirewallD is installed or running
function firewalld_check() {
  if [[ "$(firewall-cmd --state)" == "running" ]] ; then
    echo "FirewallD is installed and running on this system."
    echo "You should update FirewallD to allow the new port number if you changed it."
    echo -n "Would you like this script to update FirewallD permanently? (y/n) "
    read firewalld_update_response
    case $firewalld_update_response in
      [Yy]|[Yy][Ee][Ss]) firewalld_update ;;
      [Nn]|[Nn][Oo]) echo "FirewallD unchanged." ;;
      *) echo "Unrecognized command..." ;;
    esac 
  fi
  
  if [[ "$(firewall-cmd --state)" =~ ^.*not.*$ ]] ; then
    echo "FirewallD is installed but not running on this system."
    echo "You should update FirewallD to allow the new port number if you changed it."
    echo -n "Would you like this script to activate and update FirewallD permanently? (y/n) "
    read firewalld_update_response
    case $firewalld_update_response in
      [Yy]|[Yy][Ee][Ss]) firewalld_update ;;
      [Nn]|[Nn][Oo]) echo "FirewallD unchanged." ;;
      *) echo "Unrecognized command..." ;;
    esac 
  fi  
}

#Do sshd_config functions above interactively
function guided_config() {
  check_root
  sshd_config_check	
	
  echo -n "Back up sshd_config? (y/n) "
  read backup_response
  case $backup_response in
    [Yy]|[Yy][Ee][Ss]) backup_sshd_config ;;
    [Nn]|[Nn][Oo]) echo "No backup created" ;;
    *) echo "Unrecognized command..." ;;
  esac

  echo -n "Recommended: use only protocol 2. (y/n) "
  read protocol_response
  case $protocol_response in
    [Yy]|[Yy][Ee][Ss]) change_protocol ;;
    [Nn]|[Nn][Oo]) echo "Protocol unchanged" ;;
    *) echo "Unrecognized command..." ;;
  esac

  echo -n "Recommended: disable root login. (y/n) "
  read root_login_response
  case $root_login_response in
    [Yy]|[Yy][Ee][Ss]) root_login ;;
    [Nn]|[Nn][Oo]) echo "PermitRootLogin unchanged " ;;
    *) echo "Unrecognized command..." ;;
  esac

  echo -n "Recommended: change SSH port. (y/n) "
  read ssh_port_response
  case $ssh_port_response in
    [Yy]|[Yy][Ee][Ss]) ssh_port ;;
    [Nn]|[Nn][Oo]) echo "Port unchanged" ;;
    *) echo "Unrecognized command..." ;;
  esac

  echo -n "Recommended: change maximum authentication attempts. (y/n) "
  read authtries_response
  case $authtries_response in
    [Yy]|[Yy][Ee][Ss]) max_auth ;;
    [Nn]|[Nn][Oo]) echo "Maximum authentications attempts unchanged" ;;
    *) echo "Unrecognized command..." ;;
  esac

  echo -n "Recommended: disable empty passwords. (y/n) "
  read empty_pw_response
  case $empty_pw_response in
    [Yy]|[Yy][Ee][Ss]) empty_passwords ;;
    [Nn]|[Nn][Oo]) echo "PermitEmptyPasswords unchanged" ;;
    *) echo "Unrecognized command..." ;;
  esac

  echo -n "Recommended: reduce login gracetime. (y/n) "
  read login_gt_response
  case $login_gt_response in
    [Yy]|[Yy][Ee][Ss]) login_gt ;;
    [Nn]|[Nn][Oo]) echo "LoginGraceTime unchanged " ;;
    *) echo "Unrecognized command..." ;;
  esac

  echo -n "Recommended: disable passwords if you have SSH key-pair. (y/n) "
  read disable_pw_response
  case $disable_pw_response in
    [Yy]|[Yy][Ee][Ss]) disable_pw ;;
    [Nn]|[Nn][Oo]) echo "PasswordAuthentication unchanged " ;;
    *) echo "Unrecognized command..." ;;
  esac

  echo -n "Recommended: ignore Rhosts. (y/n) "
  read disable_rhosts_response
  case $disable_rhosts_response in
    [Yy]|[Yy][Ee][Ss]) disable_rhosts ;;
    [Nn]|[Nn][Oo]) echo "IgnoreRhosts unchanged" ;;
    *) echo "Unrecognized command..." ;;
  esac

  echo -n "Recommended: set warning banner. (y/n) "
  read warning_banner_response
  case $warning_banner_response in
    [Yy]|[Yy][Ee][Ss]) warning_banner ;;
    [Nn]|[Nn][Oo]) echo "Banner unchanged" ;;
    *) echo "Unrecognized command..." ;;
  esac

  echo -n "SELinux can interfere with SSH if it's not on port 22. Check if it's on? (y/n) "
  read selinux_check_response
  case $selinux_check_response in
    [Yy]|[Yy][Ee][Ss]) selinux_check ;;
    [Nn]|[Nn][Oo]) echo "SELinux unchecked." ;;
    *) echo "Unrecognized command..." ;;
  esac

  echo -n "FirewallD can block SSH if enabled. Check if it's on? (y/n) "
  read firewalld_check_response
  case $firewalld_check_response in
    [Yy]|[Yy][Ee][Ss]) firewalld_check ;;
    [Nn]|[Nn][Oo]) echo "FirewallD unchecked." ;;
    *) echo "Unrecognized command..." ;;
  esac
}

#Do sshd_config functions quickly
function quick_config() {
  check_root
  sshd_config_check
  backup_sshd_config
  change_protocol
  root_login
  ssh_port
  max_auth
  empty_passwords
  login_gt
  disable_pw
  disable_rhosts
  warning_banner
  selinux_check
  firewalld_check
}

#Take positional parameters, make sure they jive
if [ "$1" == "i" ]; then
  guided_config
  echo "Done! Be sure to restart sshd!"
elif [ "$1" == "q" ]; then
  quick_config
  echo "Done! Be sure to restart sshd!"
else
  echo "Start script with 'i' for interactive mode or 'q' for quick mode."
fi

