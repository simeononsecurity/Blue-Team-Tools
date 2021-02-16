#Continue on error
$ErrorActionPreference= 'silentlycontinue'

#Require elivation for script run
#Requires -RunAsAdministrator
Write-Output "Elevating priviledges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

Write-Host "Installing Applocker Policies"
ForEach ($Policy in (Get-ChildItem ./Files/).FullName){
   Set-AppLockerPolicy -XMLPolicy "$Policy" -Merge
}

# Appplocker service running?
Write-Host "Enabling AppLocker Service"
Set-Service -Name AppIdsvc -StartupType Automatic
Start-Service AppIdsvc
Get-Service -Name AppIdsvc | fl St*

#Print Conf
Write-Host "Printing AppLocker Active Rule Categories"
Get-AppLockerPolicy -Local

#Test Block Rules
#Get-AppLockerPolicy -Local | Test-AppLockerPolicy -Path C:\Windows\System32\*.exe -User Everyone | Where-Object {$_.PolicyDecision -eq "Denied"}
