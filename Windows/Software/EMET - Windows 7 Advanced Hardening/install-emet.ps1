#Continue on error
$ErrorActionPreference= 'silentlycontinue'

#Require elivation for script run
#Requires -RunAsAdministrator
Write-Output "Elevating priviledges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

#Install EMET
msiexec /i "EMET Setup.msi" /qn /norestart

#Copy EMET Conf File
Copy-Item EMET_Conf.xml "C:\Program Files (x86)\EMET 5.5"

#Conf EMET Extras
Set-Location "C:\Program Files (x86)\EMET 5.5"
.\EMET_Conf.exe --import --force ./EMET_Conf.xml
.\EMET_Conf.exe --deephooks enabled
.\EMET_Conf.exe --antidetours enabled
.\EMET_Conf.exe --eafplus enabled
.\EMET_Conf.exe --exploitaction stop
.\EMET_Conf.exe --reporting -telemetry +eventlog +trayicon
.\EMET_Conf.exe --list_system 