#Require elivation for script run
#Requires -RunAsAdministrator

#Windows Defender Configuration Files
New-Item -Path "C:\" -Name "Temp" -ItemType "directory" -Force | Out-Null; New-Item -Path "C:\temp\" -Name "Windows Defender" -ItemType "directory" -Force | Out-Null; Copy-Item -Path .\Files\XML\* -Destination "C:\temp\Windows Defender\" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null

#Enable Windows Defender Application Control
#https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/select-types-of-rules-to-create
$PolicyPath = "C:\temp\Windows Defender\WDAC_V1_Recommended_Enforced.xml"
ForEach ($PolicyNumber in (1..10)) {
    Write-Host "Importing WDAC Policy Option $PolicyNumber"
    Set-RuleOption -FilePath $PolicyPath -Option $PolicyNumber
}

#Enable the necessary services to allow WDAC to use the ISG correctly on the client
#https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/use-windows-defender-application-control-with-intelligent-security-graph#enable-the-necessary-services-to-allow-wdac-to-use-the-isg-correctly-on-the-client
appidtel start

Add-Type -AssemblyName PresentationFramework
$Answer = [System.Windows.MessageBox]::Show("Reboot to make changes effective?", "Restart Computer", "YesNo", "Question")
Switch ($Answer) {
    "Yes" { Write-Host "Performing Gpupdate"; Gpupdate /force /boot; Get-Job; Write-Warning "Restarting Computer in 15 Seconds"; Start-sleep -seconds 15; Restart-Computer -Force }
    "No" { Write-Host "Performing Gpupdate"; Gpupdate /force ; Get-Job; Write-Warning "A reboot is required for all changed to take effect" }
    Default { Write-Warning "A reboot is required for all changed to take effect" }
}

