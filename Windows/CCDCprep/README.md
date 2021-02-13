# WGU CCDC Basic Windows Checklist / First Fifteen Minutes guidelines

Make sure machine is in English
```
Control intl.cpl
```

Create backup administrator account
Name:
Password:
```
net user WGU-Admin * /ADD
net localgroup administrators WGU-Admin /add
```




Change all user passwords to strong passwords
```
Net localgroup administrators >>LocalAdministratorUsers.txt
Net user usernamehere *

Net user >>localUsers.txt
Net user username *
```




Delete or disable any unnecessary accounts

Disable
```
Net user accountname /active:no 
```
Delete
```
Net user accountname /delete
```






Enable Windows Firewall and allow some ports through
```
netsh advfirewall reset
netsh advfirewall firewall delete rule *
netsh advfirewall firewall add rule dir=in action=allow protocol=tcp localport=3389 name=”Allow-TCP-3389-RDP”
```

```
netsh advfirewall firewall add rule dir=in action=allow protocol=icmpv4 name=”Allow ICMP V4”
netsh advfirewall set domainprofile firewallpolicy blockinbound,allowoutbound
netsh advfirewall set privateprofile firewallpolicy blockinbound,allowoutbound
netsh advfirewall set publicprofile firewallpolicy blockinbound,allowoutbound
netsh advfirewall set allprofile state on

```


Check for any logged on users
```
Query session
Query user
Query process
```

Delete Unnecessary Shares on the Machine
```
Net share
Net share sharename /delete
```

Delete any scheduled tasks
```
schtasks /delete /tn * /f
```

Identify running services and processes
```
Get-service
Sc query type=service state=all
Tasklist >>RunningProcesses.Txt
```

Setup for Powershell Scripts

Powershell commands
```
Set-executionpolicy bypass -force
Disable-psremoting -force
Clear-item -path wsman:\localhost\client\trustedhosts -force
Add-windowsfeature powershell-ise
```

Enable and set to highest setting UAC
```
C:\windows\system32\UserAccountControlSettings.exe
```

Verify Certificate stores for any suspicious certs

Win 8 / 2012 or higher
```
certlm
```
```
mmc.exe 
File -> Add / Remove Snap-In -> Certificates -> Click Add->Computer Account->Local Computer->Finish
File -> Add / Remove Snap-In -> Certificates -> Click Add->My User Account->Finish
File -> Add / Remove Snap-In -> Certificates -> Click Add->Service Account->Local Computer->Select potential service accounts to review ->Finish
```


Check startup & disable unnecessary items via msconfig
```
msconfig
```

Uninstall any unnecessary software
```
Control appwiz.cpl
```
IE: remove tightvnc, aim, trillian, gaim, pidgin, any extraneous software that is not required by the given scenario.

Check browsers for any malicious or unnecessary toolbars etc
Reset the browsers if possible

Make sure Antivirus is installed!


Configure local policies (Work in progress)
```
Secpol.msc
```
Security Settings>Account Policies>Account Lockout Policy
Account Lockout Duration: 30min
Account Lockout threshold: 2 failed logins
Reset account lockout counter after: 30 mins

Local Policies>Audit Policy
Enable all for failure and success


### Preliminary Hardening
* Disable SMB
    - Win 7 way is
        ```
        Get-Item HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters | ForEach-Object {Get-ItemProperty $_.pspath}
        ```
        ```
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB1 -Type DWORD -Value 0 -Force 
        ```
        Then restart

* Disable Netbios  
https://help.hcltechsw.com/docs/onprem_2.0/2.0_CR3_install_guide/guide/text/disable_netbios_on_windows_servers.html
* Disable Login to Certain accounts
    - This is dependent on the business scenario we're given. So we'll have a snippet of how to perform the disabling but we might need to skip over this step

Get our tooling onto the machine
* Sysinternals
    - Sysmon
    https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon
    - Process Explorer
    https://docs.microsoft.com/en-us/sysinternals/downloads/process-explorer
    - AutoRuns
    https://docs.microsoft.com/en-us/sysinternals/downloads/autoruns
* BlueSpawn 
 https://bluespawn.cloud/quickstart/
* EMET (If Windows 7)
* ProcessHacker
    - https://processhacker.sourceforge.io/
