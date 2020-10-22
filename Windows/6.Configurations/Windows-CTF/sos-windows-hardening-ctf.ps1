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

#Set PowerShell Constrained Language Mode
#https://devblogs.microsoft.com/powershell/powershell-constrained-language-mode/
$ExecutionContext.SessionState.LanguageMode = "ConstrainedLanguage"

#Enable DEP
BCDEDIT /set "{current}" nx OptOut

#Disable TCP Timestamps
netsh int tcp set global timestamps=disabled

#Windows 10 Defender Configuration Files
mkdir "C:\temp\Windows Defender"; Copy-Item -Path .\Files\Windows-Defender\* -Destination C:\temp\"Windows Defender"\ -Force -Recurse -ErrorAction SilentlyContinue

#Enable Windows Defender Application Control
#https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/select-types-of-rules-to-create
Set-RuleOption -FilePath "C:\temp\Windows Defender\WDAC_V1_Enforced.xml" -Option 0

#GPO Configurations
$gposdir = "$(Get-Location)\Files\GPOs"
Foreach ($gpocategory in Get-ChildItem "$(Get-Location)\Files\GPOs") {
    
    Write-Output "Importing $gpocategory GPOs"

    Foreach ($gpo in (Get-ChildItem "$(Get-Location)\Files\GPOs\$gpocategory")) {
        $gpopath = "$gposdir\$gpocategory\$gpo"
        Write-Output "Importing $gpo"
        .\Files\LGPO\LGPO.exe /g $gpopath
    }
}

#Reboot prompt
Add-Type -AssemblyName PresentationFramework
$Answer = [System.Windows.MessageBox]::Show("Reboot to make changes effective?", "Restart Computer", "YesNo", "Question")
Switch ($Answer)
{
    "Yes"   { Write-Warning "Restarting Computer in 15 Seconds"; Start-sleep -seconds 15; Restart-Computer -Force }
    "No"    { Write-Warning "A reboot is required for all changed to take effect" }
    Default { Write-Warning "A reboot is required for all changed to take effect" }
}
