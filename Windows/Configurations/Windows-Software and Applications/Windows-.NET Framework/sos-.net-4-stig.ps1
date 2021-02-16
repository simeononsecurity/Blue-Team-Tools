#SimeonOnSecurity - Microsoft .Net Framework 4 STIG Script
#https://github.com/simeononsecurity
#https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_MS_DotNet_Framework_4-0_V1R9_STIG.zip
#https://docs.microsoft.com/en-us/dotnet/framework/tools/caspol-exe-code-access-security-policy-tool

#Continue on error
$ErrorActionPreference= 'silentlycontinue'

#Require elivation for script run
#Requires -RunAsAdministrator

#change path to script location
#https://stackoverflow.com/questions/4724290/powershell-run-command-from-scripts-directory
$currentPath=Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path

$netframework32="C:\Windows\Microsoft.NET\Framework"
$netframework64="C:\Windows\Microsoft.NET\Framework64"
$netframeworks=("$netframework32","$netframework64")

#Vul ID: V-7055	   	Rule ID: SV-7438r3_rule	   	STIG ID: APPNET0031
If (Test-Path -Path "HKLM:\Software\Microsoft\StrongName\Verification"){
    Remove-Item "HKLM:\Software\Microsoft\StrongName\Verification" -Recurse -Force
    Write-Host ".Net StrongName Verification Registry Removed"
}

#[xml]$SecureMachineConfig = Get-Content $currentPath\Files\machine.config
#Apply Machine.conf Configurations
#Foreach ($netframework in $netframeworks){
#    Write-Host $netframework
#    ForEach ($machineconfig in (Get-ChildItem -Recurse -Path $netframework machine.config).FullName){
#        Write-Host "$machineconfig"
#        ForEach ($node in ($SecureMachineConfig.DocumentElement.ChildNodes)){
#        [xml]$defaultmachineconfig=(Get-Content $machineconfig)
#        $defaultmachineconfig.ImportNode($node, $true) 
#        Write-Host "Murge Complete"
#        }
#    }
#}

# .Net 32-Bit
ForEach ($dotnet32version in (Get-ChildItem $netframework32 | ?{ $_.PSIsContainer }).Name){
    $netframework32="C:\Windows\Microsoft.NET\Framework"
    Write-Host ".Net 32-Bit $dotnet32version Is Installed"
    cmd /c $netframework32\$dotnet32version\caspol.exe -q -f -pp on 
    cmd /c $netframework32\$dotnet32version\caspol.exe -m -lg
    #Vul ID: V-30935	   	Rule ID: SV-40977r3_rule	   	STIG ID: APPNET0063
    If (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\AllowStrongNameBypass"){
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\" -Name "AllowStrongNameBypass" -Value "0" -Force
    }Else {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\" -Name ".NETFramework" -Force
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\" -Name "AllowStrongNameBypass" -PropertyType "DWORD" -Value "0" -Force
    }
    #Vul ID: V-81495	   	Rule ID: SV-96209r2_rule	   	STIG ID: APPNET0075	
    If (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\$dotnet32version\SchUseStrongCrypto"){
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\$dotnet32version\" -Name "SchUseStrongCrypto" -Value "1" -Force
    }Else {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework" -Name "$dotnet32version" -Force
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\$dotnet32version\" -Name "SchUseStrongCrypto" -PropertyType "DWORD" -Value "1" -Force
    }
}
# .Net 64-Bit
ForEach ($dotnet64version in (Get-ChildItem $netframework64 | ?{ $_.PSIsContainer }).Name){
    $netframework64="C:\Windows\Microsoft.NET\Framework64"
    Write-Host ".Net 64-Bit $dotnet64version Is Installed"
    cmd /c $netframework64\$dotnet64version\caspol.exe -q -f -pp on 
    cmd /c $netframework64\$dotnet64version\caspol.exe -m -lg
    #Vul ID: V-30935	   	Rule ID: SV-40977r3_rule	   	STIG ID: APPNET0063
    If (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\AllowStrongNameBypass") {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\" -Name "AllowStrongNameBypass" -Value "0" -Force
    }Else {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\" -Name ".NETFramework" -Force
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\" -Name "AllowStrongNameBypass" -PropertyType "DWORD" -Value "0" -Force
    }
    #Vul ID: V-81495	   	Rule ID: SV-96209r2_rule	   	STIG ID: APPNET0075	
    If (Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\$dotnet64version\") {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\$dotnet64version\" -Name "SchUseStrongCrypto" -Value "1" -Force
    }Else {
        New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\" -Name "$dotnet64version" -Force
        New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\$dotnet64version\" -Name "SchUseStrongCrypto" -PropertyType "DWORD" -Value "1" -Force
    }
}

#Vul ID: V-30937	   	Rule ID: SV-40979r3_rule	   	STIG ID: APPNET0064	  
#FINDSTR /i /s "NetFx40_LegacySecurityPolicy" c:\*.exe.config 
