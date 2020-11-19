# Windows-Hardening-CTF
A windows hardening script that makes it difficult and more annoying to compromise a Windows device.

## What does this script do?
- Disables Command Prompt
- Disables LLMNR
- Disables PowerShell v2
- Disables SMB Compression
- Disables SMB v1
- Disables SMB v2
- Disables TCP Timestamps
- Disables WSMAN and PSRemoting
- Enables AppLocker with NSA Recommended Policies
- Enables Best practice Windows Logging and Security Controls
- Enables DEP
- Enables EMET Configurations (Only applies to systems with EMET installed)
- Enables PowerShell Constrined Language Mode
- Enables PowerShell Logging
- Enables SMB Encryption
- Enables Spectre and Meltdown Mitigations
- Enables Windows Defender Application Control
- Enables Windows Defender Attack Surface Reduction Procections
- Enables Windows Defender Cloud-based Protections
- Enables Windows Defender Exploit Protections
- Enables Windows Firewall and Logging
- Installs PSWindowsUpdate and Installs all Available Windows Updates

## Download the required files:

Download the required files from the [GitHub Repository](https://github.com/simeononsecurity/Windows-Hardening-CTF)

## How to run the script:

**The script may be lauched from the extracted GitHub download like this:**
```
.\sos-windows-hardening-ctf.ps1
```
