# Windows-Defender-Application-Control-Hardening

Harden Windows with Windows Defender Application Control (WDAC)

## A list of scripts and tools this collection utilizes:

- [MicrosoftDocs - WDAC-Toolkit](https://github.com/MicrosoftDocs/WDAC-Toolkit)

## Additional configurations were considered from:

- [Microsoft - Recommended block rules](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/microsoft-recommended-block-rules)
- [Microsoft - Recommended driver block rules](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/microsoft-recommended-driver-block-rules)
- [Microsoft - Windows Defender Application Control](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/windows-defender-application-control-design-guide)

## Explanation:

### XML vs. BIN:

- Simply put, the **"XML"** policies are for applying to a machine locally and the **"BIN"** files are for enforcing them with either [Group Policy](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/deploy-windows-defender-application-control-policies-using-group-policy) or [Microsoft Intune](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/deploy-windows-defender-application-control-policies-using-intune).

### Policy Descriptions:

- **Default Policies:**
  - The "Default" policies use only the default features available in the WDAC-Toolkit.
- **Recommended Policies:**
  - The "Recommended" policies use the default features as well as Microsoft's recommended [blocks](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/microsoft-recommended-block-rules) and [driver block](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/microsoft-recommended-driver-block-rules) rules.
- **Audit Policies:**
  - The "Audit" policies, just log exceptions to the rules. This is for testing in your environment, so that you may modify the policies, at will, to fit your environments needs.
- **Enforced Policies:**
  - The "Enforced" policies will not allow any exceptions to the rules, applications, drivers, dlls, etc. will be blocked if they do not comply.

### Available Policies:

- **XML:**
  - **Audit Only:**
    - `WDAC_V1_Default_Audit.xml`
    - `WDAC_V1_Recommended_Audit.xml`
  - **Enforced:**
    - `WDAC_V1_Default_Enforced.xml`
    - `WDAC_V1_Recommended_Enforced.xml`
- **BIN:**
  - **Audit Only:**
    - `WDAC_V1_Default_Audit.bin`
    - `WDAC_V1_Recommended_Audit.bin`
  - **Enforced:**
    - `WDAC_V1_Default_Enforced.bin`
    - `WDAC_V1_Recommended_Enforced.bin`

Update the following line in the script to use the policy that you desire locally:

```powershell
$PolicyPath = "C:\temp\Windows Defender\WDAC_V1_Recommended_Enforced.xml"
ForEach ($PolicyNumber in (1..10)) {
    Write-Host "Importing WDAC Policy Option $PolicyNumber"
    Set-RuleOption -FilePath $PolicyPath -Option $PolicyNumber
}
```

Alternatively, you may use [Group Policy](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/deploy-windows-defender-application-control-policies-using-group-policy) or [Microsoft Intune](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/deploy-windows-defender-application-control-policies-using-intune) to enforce the WDAC policies.

## Auditing:

You can view the WDAC event logs in event viewer under:

`Applications and Services Logs\Microsoft\Windows\CodeIntegrity\Operational`

## Recommended Reading:

- [Microsoft - Audit Windows Defender Application Control Policies](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/audit-windows-defender-application-control-policies)
- [Microsoft - Deploy Windows Defender Application Control policies by using Group Policy](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/deploy-windows-defender-application-control-policies-using-group-policy)
- [Microsoft - Deploy Windows Defender Application Control policies by using Microsoft Intune](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/deploy-windows-defender-application-control-policies-using-intune)
- [Microsoft - Enforce Windows Defencer Application Control Policies](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/enforce-windows-defender-application-control-policies)

## How to run the script:

### Manual Install:

If manually downloaded, the script must be launched from an administrative powershell in the directory containing all the files from the [GitHub Repository](https://github.com/simeononsecurity/Windows-Defender-Application-Control-Hardening/archive/main.zip)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
Get-ChildItem -Recurse *.ps1 | Unblock-File
.\sos-wdachardening.ps1
```
