######Script for Import and Setup of GPOs and Policy Definitons on Domain Controllers#####
#Continue on error
$ErrorActionPreference= 'silentlycontinue'

#Require elivation for script run
#Requires -RunAsAdministrator
Write-Output "Elevating priviledges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)


#Import PolicyDefinitions
    #Import Locally
Start-Job -ScriptBlock {takeown /f C:\WINDOWS\PolicyDefinitions /r /a; icacls C:\WINDOWS\PolicyDefinitions /grant Administrators:(OI)(CI)F /t; Copy-Item -Path .\Files\PolicyDefinitions\* -Destination C:\Windows\PolicyDefinitions -Force -Recurse -ErrorAction SilentlyContinue}
    #Import to Central Store
Foreach ($sysvolpath in Get-ChildItem "C:\Windows\SYSVOL\sysvol") {
    New-Item "C:\Windows\SYSVOL\sysvol\$sysvolpath\Policies\PolicyDefinitions\" -Force
    Copy-Item -Path "$(Get-Location)\Files\PolicyDefinitions\*" -Destination "C:\Windows\SYSVOL\sysvol\$sysvolpath\Policies\PolicyDefinitions\" -Force -Recurse
}

#Import GPOS into GPMC
$gposdir = "$(Get-Location)\Files\GPOs"
Foreach ($gpocategory in Get-ChildItem $gposdir) {
    
    Write-Output "Importing $gpocategory GPOs"

    Foreach ($gpo in (Get-ChildItem "$gposdir\$gpocategory")) {
        $gpopath = "$gposdir\$gpocategory\$gpo"
        Write-Output "Importing $gpo"
        New-GPO -Name "$gpo" -Comment "Created by simeononsecurity.ch" 
        Import-GPO -BackupGpoName "$gpo" -Path "$gpopath" -TargetName "$gpo" -CreateIfNeeded 
    }
}

