<#
.SYNOPSIS
    Applies changes to IIs 8.5 configuration to be STIG compliant.

.DESCRIPTION
    This powershell script applies several configuration changes to an IIs 8.5 configuration to meet STIG guidance.
    Script is applicable to "Web Server Security Requirements Guide"
    Version 16.4 =  V2R2 23OCT2015
    Version 17.1 =  V2R2 23OCT2015
    Version 17.2 =  V2R2 23OCT2015
    Changed script to match requirements in IIs 8.5 Server & Site STIGs v1r1 12SEP17
    Version 18.1 = V1R1 12SEP17
    Version 18.2 = V1R2 26JAN18
    Version 18.2a = V1R3 27APR18
    
.EXAMPLE
    .\IIs85-Lock_v18.2.ps1


.NOTES

    Original Author:   Jon Pemberton, Microsoft Consulting Services - Jon.Pemberton@microsoft.com
    Revision History:  
    R100 - 10/24/2016 - Initial version complete
    17.1 - 01/25/2017 - Changed Require client certificates to Negotiate (SslRequireCert to SslNegotiateCert), fixed typo.
                        Removed SRG-AP-000001-WSR-000001 / V-40791 and SRG-AP-000295-WSR-000134,12 / V-55949 & V-55951 as default IIs 8.5 configuration is compliant with SRG.
    17.2 - 06/06/2017 - Added registry keys to enable TLS 1.1 and TLS 1.2
    17.3 - 07/13/2017 - Major Revision, Script now aligns with draft IIs 8.5 Server & Site STIGs
    18.1 - 01/18/2018 - Major Revision, Script now aligns with IIs 8.5 Server & Site STIGs v1r1, added list of checks considered manual checks
    18.2 - 03/22/2018 - Minor Revisions, updated 4 items from v1r2 version of STIG, V-76723, V-76725, V-76727, and V-76777 changed value from "Use URI" to "Use Cookies" per STIG update
    18.2a - 05/14/2018 - Minor Revisionss, updated items from v1r3 version of the STIGs, V-76771 change config from .NET Authoriztion to URL Authorization, Removed "HTTP_Connection" from V-76687,
                         Removed "HTTP_USER_AGENT" from V-76689, Removed V-76853, V-76857, V-76863 as these had duplicate requirements to V-76851, V-76859, V-76861 respectively
 ------------------------------------------------------------------------
               Copyright (C) 2016 Microsoft Corporation

 You have a royalty-free right to use, modify, reproduce and distribute
 this sample script (and/or any modified version) in any way
 you find useful, provided that you agree that Microsoft has no warranty,
 obligations or liability for any sample application or script files.
 ------------------------------------------------------------------------
#>