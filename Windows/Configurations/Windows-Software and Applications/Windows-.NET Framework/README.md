# Automate the .NET Framework STIG

Applying the .NET STIG is definitely not straightforward. For many administrators it can take hours to fully implement on a single system. This script applies the required registry changes and modifies the machine.config file to implement FIPS and other controls as required.

**Work in Progress**

**DO NOT APPLY IN PRODUCTION**

## Notes:

This script can not and will not ever get the .NET stig to 100% compliance. 
Manual intervention is required for any .NET application or IIS Site.

## STIGS/SRGs Applied:

- [Microsoft .Net Framework 4 V1R9](https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_MS_DotNet_Framework_4-0_V1R9_STIG.zip)

## Sources:

- [Microsoft .NET Framework Documentation](https://docs.microsoft.com/en-us/dotnet/framework/)

## Download the required files

You may download the required files from the [GitHub Repository](https://raw.githubusercontent.com/simeononsecurity/.NET-STIG-Script/)

## How to run the script

**The script may be lauched from the extracted GitHub download like this:**

```
.\sos-.net-4-stig.ps1
```
