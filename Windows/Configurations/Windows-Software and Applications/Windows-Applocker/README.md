# Applocker-Hardening
Ultimate Applocker Hardening Configuration Script.

## What does this script do?
- Locks down system resources to bare minumum needed for basic OS functionality

## Recommended reading:
- [api0cradle/UltimateAppLockerByPassList)](https://github.com/api0cradle/UltimateAppLockerByPassList)
- [Microsoft Recommended Block Rules](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/microsoft-recommended-block-rules)
- [MotiBa/AppLocker](https://github.com/MotiBa/AppLocker)
- [NSA Cyber Bitlocker Gidance](https://github.com/nsacyber/AppLocker-Guidance)

## How to run the script:
### Manual Install:
If manually downloaded, the script must be launched from an administrative powershell in the directory containing all the files from the [GitHub Repository](https://github.com/simeononsecurity/Applocker-Hardening)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
Get-ChildItem -Recurse *.ps1 | Unblock-File
.\sos-applockerhardening.ps1
```
### Automated Install:
The script may be launched from the extracted GitHub download like this:
```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://simeononsecurity.ch/scripts/sosapplocker.ps1'))
```
