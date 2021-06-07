#####Windows Hardening CTF#####
#Continue on error
$ErrorActionPreference= 'silentlycontinue'

#Require elivation for script run
Requires -RunAsAdministrator
Write-Output "Elevating priviledges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

#Disable CMD Interactive
#reg add HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\System /v DisableCMD /t REG_DWORD /d 2 /f
#Disable CMD Interactive and CMD Inline 
reg add HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\System /v DisableCMD /t REG_DWORD /d 1 /f

#Automatically exit CMD when opened
reg add "HKEY_CURRENT_USER\Software\Microsoft\Command Processor" /v AutoRun /t REG_EXPAND_SZ /d "exit"

#Disable Powershell v2
Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root
Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2

#Set PowerShell Constrained Language Mode
#https://devblogs.microsoft.com/powershell/powershell-constrained-language-mode/
$ExecutionContext.SessionState.LanguageMode = "ConstrainedLanguage"
Set-Variable -Name "__PSLockdownPolicy" -Value "4"

#Enable PowerShell Logging
#https://www.digitalshadows.com/blog-and-research/powershell-security-best-practices/
#https://www.cyber.gov.au/acsc/view-all-content/publications/securing-powershell-enterprise
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription" -Name "OutputDirectory" -Type "STRING" -Value "C:\PowershellLogs" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging\" -Name "EnableScriptBlockLogging" -Type "DWORD" -Value "1" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription\" -Name "EnableTranscripting" -Type "DWORD" -Value "1" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription\" -Name "EnableInvocationHeader" -Type "DWORD" -Value "1" -Force

#Remove WSMan listeners
Get-ChildItem WSMan:\Localhost\listener | Where-Object -Property Keys -eq "Transport=HTTP" | Remove-Item -Recurse
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse
#Disable the WSMan Service
Set-Service -Name "WinRM" -StartupType Disabled -Status Stopped
#Disable Firewall Rule
Disable-NetFirewallRule -DisplayName “Windows Remote Management (HTTP-In)”
