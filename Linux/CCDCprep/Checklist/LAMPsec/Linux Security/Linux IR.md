


## Key Incident Response Steps
(via the following links)

[**intrusion discovery cheatsheet**](https://www.sans.org/security-resources/posters/intrusion-discovery-cheat-sheet-linux/230/download)

[**security incident survey cheatsheet**](https://zeltser.com/media/docs/security-incident-survey-cheat-sheet.pdf)


1. Preparation: Gather and learn the necessary tools,
become familiar with your environment.
2. Identification: Detect the incident, determine its
scope, and involve the appropriate parties.
3. Containment: Contain the incident to minimize its
effect on neighboring IT resources.
4. Eradication: Eliminate compromise artifacts, if
necessary, on the path to recovery.
5. Recovery: Restore the system to normal
operations, possibly via reinstall or backup.
6. Wrap‐up: Document the incident’s details, retail
collected data, and discuss lessons learned.

Unix Initial System Examination

Look at event log files in
directories (locations vary)
```
/var/log,
/var/adm,
/var/spool
```
List recent security events
```
wtmp
who
last
lastlog
```

Examine network
configuration
```
arp –an
route print
```
List network
connections and
related details
```
netstat –nap (Linux),
netstat –na (Solaris),
lsof –i
```
List users 
```
more /etc/passwd
```
Look at scheduled
jobs
```
more /etc/crontab,
ls /etc/cron.*,
ls /var/at/jobs
```
Check DNS settings
and the hosts file
```
more /etc/resolv.conf,
more /etc/hosts
```
Verify integrity of installed
packages (affects lots of files!)
```
rpm ‐Va (Linux),
pkgchk (Solaris)
```
Look at auto‐
start services
```
chkconfig ‐‐list (Linux),
ls /etc/rc*.d (Solaris),
smf (Solaris 10+)
```
List processes ps aux (Linux, BSD),
```
ps ‐ef (Solaris),
lsof +L1
```
Find recently‐modified files
(affects lots of files!)
```
ls –lat /
find / ‐mtime ‐2d ‐ls
```

Unusual Accounts

Look in /etc/passwd for new accounts in sorted list by
UID:
```
sort –nk3 –t: /etc/passwd | less
```
Normal accounts will be there, but look for new,
unexpected accounts, especially with UID < 500.
Also, look for unexpected UID 0 accounts:
```
 egrep ':0+:' /etc/passwd
``` 
On systems that use multiple authentication methods:
```
 getent passwd | egrep ':0+:'
```
Look for orphaned files, which could be a sign of an
attacker's temporary account that has been deleted.
```
find / -nouser -print
```
Unusual Log Entries

Look through your system log files for suspicious
events, including:

"entered promiscuous mode"

Large number of authentication or login
failures from either local or remote access
tools (e.g., telnetd, sshd, etc.)

Remote Procedure Call (rpc) programs with a
log entry that includes a large number (> 20)
strange characters (such as ^PM-^PM-^PM-
^PM-^PM-^PM-^PM-^PM)

For systems running web servers: Larger than
normal number of Apache logs saying "error"
Reboots and/or application restarts

Other Unusual Items

Sluggish system performance:
```
$ uptime – Look at "load average"
```
Excessive memory use: 
```
$ free
```
Sudden decreases in available disk space:
```
$ df
```
Unusual Processes and Services

Look at all running processes:
```
ps –aux
```
Get familiar with "normal" processes for the machine.
Look for unusual processes. Focus on processes with
root (UID 0) privileges.

If you spot a process that is unfamiliar, investigate in
more detail using:
```
lsof –p [pid]
ps -eaf --forest
ls -al /proc/<PID>
```
This command shows all files and ports used by the
running process.

If your machine has it installed, run chkconfig to see
which services are enabled at various runlevels:
```
chkconfig --list
```
Unusual Files

Look for unusual SUID root files:
```
find / -uid 0 –perm -4000 –print
```
This requires knowledge of normal SUID files.

Look for unusual large files (greater than 10
MegaBytes):
```
 find / -size +10000k –print
```
This requires knowledge of normal large files.

Look for files named with dots and spaces ("...", ".. ",
". ", and " ") used to camouflage files:
```
 find / -name " " –print
 find / -name ".. " –print
 find / -name ". " –print
 find / -name " " –print
```
Look for processes running out of or accessing files
that have been unlinked (i.e., link count is zero). An
attacker may be hiding data in or running a backdoor
from such files:
```
 lsof +L1
```
On a Linux machine with RPM installed (RedHat,
Mandrake, etc.), run the RPM tool to verify packages:
```
 rpm –Va | sort
```
This checks size, MD5 sum, permissions, type,
owner, and group of each file with information from
RPM database to look for changes. Output includes:
S – File size differs
M – Mode differs (permissions)
5 – MD5 sum differs
D – Device number mismatch
L – readLink path mismatch
U – user ownership differs
G – group ownership differs
T – modification time differs
Pay special attention to changes associated with
items in /sbin, /bin, /usr/sbin, and /usr/bin.
In some versions of Linux, this analysis is automated
by the built-in check-packages script.

Unusual Network Usage
Look for promiscuous mode, which might indicate a
sniffer:
```
 ip link | grep PROMISC
```
Note that the ifconfig doesn’t work reliably for
detecting promiscuous mode on Linux kernel 2.4, so
please use "ip link" for detecting it.

Look for unusual port listeners:
```
netstat –nap
```
Get more details about running processes listening
on ports:
```
lsof –i
```
These commands require knowledge of which TCP
and UDP ports are normally listening on your
system. Look for deviations from the norm.
Look for unusual ARP entries, mapping IP address to
MAC addresses that aren’t correct for the LAN:
```
 arp –a
```

This analysis requires detailed knowledge of which
addresses are supposed to be on the LAN. On a
small and/or specialized LAN (such as a DMZ), look
for unexpected IP addresses.

Unusual Scheduled Tasks

Look for cron jobs scheduled by root and any other
UID 0 accounts:
```
crontab –u root –l
```
Look for unusual system-wide cron jobs:
```
 cat /etc/crontab
 ls /etc/cron.*
```
---------------

```
ip a
ls -latr /
ls -latr /tmp
ls -latr .
ls -latr ..
sudo ls -latr /root/
sudo ps -elfH
ifconfig
sudo netstat -auntp
w
sudo ls -latr /var/spool/cron
date -u
uname -a
df
ls -latr /var/acc
ls -latr /var/log/
```
```
sudo ls -latr /var/log/*
```

cat out relevant files (grep for your logged in user account)
```
sudo ls -la /etc/syslog 
```
 read all the config files 
```    
for user in $(cut -f1 -d: /etc/passwd); do echo "###### $user crontab is:"; cat -v /var/spool/cron/{crontabs/$user,$user} 2>/dev/null; done

cat -v /etc/crontab 

ls -la /etc/cron.*
```
    As needed, examine the files/scripts shown in the directory listing of the cron.* directories

```
sudo find / ( -path /proc -prune -o -path /sys -prune ) -o -mmin -8 -type f -print0 | sudo xargs -0 /bin/ls -latr 
```
   (NOTE there is a "-" a.k.a minus symbol preceding the "<duration since initial connection">
```
sestatus OR getenforce
sudo cat -v /root/.bash_history
cat -v ~/.bash_history
cat -v ~/.ssh/authorized_keys
```
## Linux Priv Users Check
```
w 

who -Ha (PID)

netstat -auntp

ps -elfH 

last 

sudo cat -v /root/.bash_history ( is admin active)

cat -v /etc/sudoers ( sometimes called wheels)

cat -v /etc/group

cat -v /etc/passwd

groups <user>
``` 
 
## Frameworks
[**mitre matrices**](https://attack.mitre.org/matrices/enterprise/)
[**NIST cyberframework**](https://www.nist.gov/cyberframework)
## Linux Basics
[**SANS Linux 101 cheatsheet**](https://wiki.sans.blue/Tools/pdfs/LinuxCLI101.pdf)

[**windows to unix cheatsheet**](https://digital-forensics.sans.org/media/windows_to_unix_cheatsheet.pdf?msc=Cheat+Sheet+Blog)

[**hex and regex cheatsheet**](https://digital-forensics.sans.org/media/hex_file_and_regex_cheat_sheet.pdf?msc=Cheat+Sheet+Blog)
[**windows and linux cli cheatsheet**](https://assets.contentstack.io/v3/assets/blt36c2e63521272fdc/bltea7de5267932e94b/5eb08aafcf88d36e47cf0644/Cheatsheet_SEC301-401_R7.pdf)

## Network
[**tshark man page**](https://linux.die.net/man/1/tshark)

[**tcpdump docs**](https://www.tcpdump.org/index.html#documentation)

[**BHIS tcpdump tutorial**](https://www.blackhillsinfosec.com/getting-started-with-tcpdump/)

[**tcpdump cheatsheet**](https://packetlife.net/media/library/12/tcpdump.pdf)

[**SANS TCP/IP cheatsheet**](https://www.sans.org/security-resources/tcpip.pdf?msc=Cheat+Sheet+Blog)

[**zeek docs**](https://docs.zeek.org/en/master/)

[**wireshark docs**](https://www.wireshark.org/docs/)

[**palo alto wireshark tutorials**](https://unit42.paloaltonetworks.com/tag/wireshark-tutorial/)

[**nmap cheatsheet**](https://assets.contentstack.io/v3/assets/blt36c2e63521272fdc/blte37ba962036d487b/5eb08aae26a7212f2db1c1da/NmapCheatSheetv1.1.pdf)

[**pivoting cheatsheet**](https://assets.contentstack.io/v3/assets/blt36c2e63521272fdc/blt0f228a4b9a1165e4/5ef3d602395b554cb3523e7b/pivot-cheat-sheet-v1.0.pdf)

## Enumeration and artifacts
[**Fastir artifact collector script**](https://github.com/SekoiaLab/Fastir_Collector_Linux)

## Binaries and Memory Forensics
[**Strings manual**](https://linux.die.net/man/1/strings)
Unless it's obfuscated you should be able to see the contents/commands in a suspicious binary. 
[**analyzing malicious documents cheatsheet**](https://digital-forensics.sans.org/media/analyzing-malicious-document-files.pdf?msc=Cheat+Sheet+Blog)

[**malware analysis cheatsheet**](https://digital-forensics.sans.org/media/malware-analysis-cheat-sheet.pdf?msc=Cheat+Sheet+Blog)

[**lime (extract linux memory for Volatility to use)**](https://github.com/504ensicslabs/lime)

[**Install Volatility**](https://github.com/volatilityfoundation/volatility/wiki/Installation)

[**Use Volatility**](https://github.com/volatilityfoundation/volatility/wiki/Volatility-Usage)

[**Volatility commands**](https://github.com/volatilityfoundation/volatility/wiki/Command-Reference)

[**Volatility wiki**](https://github.com/volatilityfoundation/volatility/wiki)

[**Volatility wiki linux section**](https://github.com/volatilityfoundation/volatility/wiki/Linux)

[**Volatility wiki links to documentation**](https://github.com/volatilityfoundation/volatility/wiki/Volatility-Documentation-Project)

[**SANS Volatility cheatsheet**](https://digital-forensics.sans.org/media/volatility-memory-forensics-cheat-sheet.pdf?msc=Cheat+Sheet+Blog)


## Further Reading/Resources
[**awesome IR**](https://github.com/meirwah/awesome-incident-response)





