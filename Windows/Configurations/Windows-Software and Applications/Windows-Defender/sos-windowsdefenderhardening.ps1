#Continue on error
$ErrorActionPreference= 'silentlycontinue'

#Require elivation for script run
Write-Output "Elevating priviledges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

#Windows Defender Configuration Files
mkdir "C:\temp\Windows Defender"; Copy-Item -Path .\Files\"Windows Defender Configuration Files"\* -Destination C:\temp\"Windows Defender"\ -Force -Recurse -ErrorAction SilentlyContinue

#Enable Windows Defender Exploit Protection
Set-ProcessMitigation -PolicyFilePath "C:\temp\Windows Defender\DOD_EP_V3.xml"

#Enable Windows Defender Application Control
#https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/select-types-of-rules-to-create
Set-RuleOption -FilePath "C:\temp\Windows Defender\WDAC_V1_Enforced.xml" -Option 0

#Windows Defender Hardening
#https://www.powershellgallery.com/packages/WindowsDefender_InternalEvaluationSetting
#Enable real-time monitoring
Write-Host "Enable real-time monitoring"
Set-MpPreference -DisableRealtimeMonitoring 0
#Enable cloud-deliveredprotection
Write-Host "Enable cloud-deliveredprotection"
Set-MpPreference -MAPSReporting Advanced
#Enable sample submission
Write-Host "Enable sample submission"
Set-MpPreference -SubmitSamplesConsent Always
#Enable checking signatures before scanning
Write-Host "Enable checking signatures before scanning"
Set-MpPreference -CheckForSignaturesBeforeRunningScan 1
#Enable behavior monitoring
Write-Host "Enable behavior monitoring"
Set-MpPreference -DisableBehaviorMonitoring 0
#Enable IOAV protection
Write-Host "Enable IOAV protection"
Set-MpPreference -DisableIOAVProtection 0
#Enable script scanning
Write-Host "Enable script scanning"
Set-MpPreference -DisableScriptScanning 0
#Enable removable drive scanning
Write-Host "Enable removable drive scanning"
Set-MpPreference -DisableRemovableDriveScanning 0
#Enable Block at first sight
Write-Host "Enable Block at first sight"
Set-MpPreference -DisableBlockAtFirstSeen 0
#Enable potentially unwanted apps
Write-Host "Enable potentially unwanted apps"
Set-MpPreference -PUAProtection Enabled
#Schedule signature updates every 8 hours
Write-Host "Schedule signature updates every 8 hours"
Set-MpPreference -SignatureUpdateInterval 8
#Enable archive scanning
Write-Host "Enable archive scanning"
Set-MpPreference -DisableArchiveScanning 0
#Enable email scanning
Write-Host "Enable email scanning"
Set-MpPreference -DisableEmailScanning 0
#Enable File Hash Computation
Write-Host "Enable File Hash Computation"
Set-MpPreference -EnableFileHashComputation 1
#Enable Intrusion Prevention System
Write-Host "Enable Intrusion Prevention System"
Set-MpPreference -DisableIntrusionPreventionSystem $false

if (!(Check-IsWindows10-1709))
{
#Enable Windows Defender Exploit Protection
Write-Host "Enabling Exploit Protection"
Set-ProcessMitigation -PolicyFilePath C:\temp\"Windows Defender"\DOD_EP_V3.xml
#Set cloud block level to 'High'
Write-Host "Set cloud block level to 'High'"
Set-MpPreference -CloudBlockLevel High
#Set cloud block timeout to 1 minute
Write-Host "Set cloud block timeout to 1 minute"
Set-MpPreference -CloudExtendedTimeout 50
Write-Host "`nUpdating Windows Defender Exploit Guard settings`n" -ForegroundColor Green 
#Enabling Controlled Folder Access and setting to block mode
Write-Host "Enabling Controlled Folder Access and setting to block mode"
Set-MpPreference -EnableControlledFolderAccess Enabled 
#Enabling Network Protection and setting to block mode
Write-Host "Enabling Network Protection and setting to block mode"
Set-MpPreference -EnableNetworkProtection Enabled

#Enable Cloud-delivered Protections
Set-MpPreference -MAPSReporting Advanced
Set-MpPreference -SubmitSamplesConsent SendAllSamples

#Enable Windows Defender Attack Surface Reduction Rules
#https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/enable-attack-surface-reduction
#https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/attack-surface-reduction
#Block executable content from email client and webmail
Add-MpPreference -AttackSurfaceReductionRules_Ids BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550 -AttackSurfaceReductionRules_Actions Enabled
#Block all Office applications from creating child processes
Add-MpPreference -AttackSurfaceReductionRules_Ids D4F940AB-401B-4EFC-AADC-AD5F3C50688A -AttackSurfaceReductionRules_Actions Enabled
#Block Office applications from creating executable content
Add-MpPreference -AttackSurfaceReductionRules_Ids 3B576869-A4EC-4529-8536-B80A7769E899 -AttackSurfaceReductionRules_Actions Enabled
#Block Office applications from injecting code into other processes
Add-MpPreference -AttackSurfaceReductionRules_Ids 75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84 -AttackSurfaceReductionRules_Actions Enabled
#Block JavaScript or VBScript from launching downloaded executable content
Add-MpPreference -AttackSurfaceReductionRules_Ids D3E037E1-3EB8-44C8-A917-57927947596D -AttackSurfaceReductionRules_Actions Enabled
#Block execution of potentially obfuscated scripts
Add-MpPreference -AttackSurfaceReductionRules_Ids 5BEB7EFE-FD9A-4556-801D-275E5FFC04CC -AttackSurfaceReductionRules_Actions Enabled
#Block Win32 API calls from Office macros
Add-MpPreference -AttackSurfaceReductionRules_Ids 92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B -AttackSurfaceReductionRules_Actions Enabled
#Block executable files from running unless they meet a prevalence, age, or trusted list criterion
Add-MpPreference -AttackSurfaceReductionRules_Ids 01443614-cd74-433a-b99e-2ecdc07bfc25 -AttackSurfaceReductionRules_Actions Enabled
#Use advanced protection against ransomware
Add-MpPreference -AttackSurfaceReductionRules_Ids c1db55ab-c21a-4637-bb3f-a12568109d35 -AttackSurfaceReductionRules_Actions Enabled
#Block credential stealing from the Windows local security authority subsystem
Add-MpPreference -AttackSurfaceReductionRules_Ids 9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2 -AttackSurfaceReductionRules_Actions Enabled
#Block process creations originating from PSExec and WMI commands
Add-MpPreference -AttackSurfaceReductionRules_Ids d1e49aac-8f56-4280-b9ba-993a6d77406c -AttackSurfaceReductionRules_Actions AuditMode
#Block untrusted and unsigned processes that run from USB
Add-MpPreference -AttackSurfaceReductionRules_Ids b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4 -AttackSurfaceReductionRules_Actions Enabled
#Block Office communication application from creating child processes
Add-MpPreference -AttackSurfaceReductionRules_Ids 26190899-1602-49e8-8b27-eb1d0a1ce869 -AttackSurfaceReductionRules_Actions Enabled
#Block Adobe Reader from creating child processes
Add-MpPreference -AttackSurfaceReductionRules_Ids 7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c -AttackSurfaceReductionRules_Actions Enabled
#Block persistence through WMI event subscription
Add-MpPreference -AttackSurfaceReductionRules_Ids e6db77e5-3df2-4cf1-b95a-636979351e5b -AttackSurfaceReductionRules_Actions Enabled
}else{
    ## Workaround for Windows 10 version 1703
    "Set cloud block level to 'High'"
    SetRegistryKey -key MpCloudBlockLevel -value 2

    "Set cloud block timeout to 1 minute"
    SetRegistryKey -key MpBafsExtendedTimeout -value 50
}

.\Files\LGPO\LGPO.exe /g .\Files\GPO\