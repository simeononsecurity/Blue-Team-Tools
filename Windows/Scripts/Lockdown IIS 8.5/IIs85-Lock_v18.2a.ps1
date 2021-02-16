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
#Requires -Version 3.0
#Requires -RunAsAdministrator


<#  
.SYNOPSIS
    Write-Log function
     
.PARAMETER -msg [string]
  Specifies the message to be logged
.PARAMETER -terminate [switch]  
  Used to create error log output and terminates the script
.PARAMETER -warn [switch]  
  Used to create warning output
.PARAMETER -err [switch]  
  Used to create error log output
#>

function Write-Log
{
    param([string]$msg, [switch]$terminate, [switch]$warn, [switch]$err)

    if($terminate)
    {
        $msg = "[$(get-date -Format HH:mm:ss)] FATAL ERROR: " + $msg
        add-content -Path $errlogfile -Value $msg
        throw $msg
    }
    elseif($err)
    {
        $msg = "[$(get-date -Format HH:mm:ss)] ERROR: " + $msg
        add-content -Path $errlogfile -Value $msg
        Write-host $msg -ForegroundColor Red
    }
    elseif($warn)
    {
        Write-Warning $msg
        $msg = "[$(get-date -Format HH:mm:ss)] WARNING: " + $msg
        add-content -Path $logfile -Value $msg
    }
    else
    {
    $msg = "[$(get-date -Format HH:mm:ss)] " + $msg
    write-host $msg
    add-content -Path $logfile -Value $msg
    }

}

# Setup log files
$scriptName = $MyInvocation.MyCommand.Name
$dateStamp = get-date -Format yyyyMMdd_HHmmss
[string]$logfile = "$scriptName`_$dateStamp.log"
[string]$errlogfile = "$scriptName`_$dateStamp`_error.log"

set-content -Path $logfile  -Value "Log started $(get-date)"
set-content -Path $errlogfile  -Value "Log started $(get-date)"

# Script variables
$servername = $env:computername
$backupname = "$servername-$datestamp-iis"
$websites = get-website
$version = "18.2"
[string]$regDate = (get-date)

New-PSDrive -name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

write-log -msg "$version IIS 8.5 Hardening Script"
write-log -msg ""


#BEGIN IIS 8.5 Server STIG Items
<#Listing IIS 8.5 Server STIG Items not included in script as they are manual checks or vary greatly for implementations, or will be re-evaluated in next release of script
IISW-SV-000100/ V-76679  IISW-SV-000132/ V-76721  IISW-SV-000/ V-76
IISW-SV-000109/ V-76685  IISW-SV-000136/ V-76729  IISW-SV-000/ V-76
IISW-SV-000113/ V-76691  IISW-SV-000139/ V-76735  IISW-SV-000/ V-76
IISW-SV-000114/ V-76693  IISW-SV-000140/ V-76737  IISW-SV-000/ V-76
IISW-SV-000115/ V-76695  IISW-SV-000141/ V-76739  IISW-SV-000/ V-76
IISW-SV-000116/ V-76697  IISW-SV-000142/ V-76741  IISW-SV-000/ V-76
IISW-SV-000117/ V-76699  IISW-SV-000143/ V-76743  IISW-SV-000/ V-76
IISW-SV-000118/ V-76701  IISW-SV-000144/ V-76745  IISW-SV-000/ V-76
IISW-SV-000119/ V-76703  IISW-SV-000145/ V-76747  IISW-SV-000/ V-76
IISW-SV-000121/ V-76707  IISW-SV-000147/ V-76749  IISW-SV-000/ V-76
IISW-SV-000123/ V-76709  IISW-SV-000148/ V-76751  IISW-SV-000/ V-76
IISW-SV-000125/ V-76713  IISW-SV-000149/ V-76753  IISW-SV-000/ V-76
IISW-SV-000129/ V-76715  IISW-SV-000151/ V-76755  IISW-SV-000/ V-76
IISW-SV-000130/ V-76717  IISW-SV-000155/ V-76763  IISW-SV-000/ V-76
IISW-SV-000131/ V-76719  IISW-SV-000156/ V-76765  IISW-SV-000/ V-76
#>
try
{

    write-log -msg "Beginning backup"
    Backup-WebConfiguration -name "$backupname" -ea Stop
    write-log -msg "Backup is stored at %WINDIR%\System32\inetsrv\backup\<$backupname>"
    write-log -msg "Backup Completed"

    write-log -msg ""
    write-log -msg "Starting IIs Configuration"
    write-log -msg "Configuring for IISW-SV-000102 / V-76681"
    set-service w3logsvc -StartupType Automatic
    sc.exe config w3svc depend= "WAS/HTTP/EVENTLOG"

    write-log -msg "Configuring for IISW-SV-000120 / V-76705"
    $chkdir = "C:\program files\common files\system\msadc"
    $chkdir2 = "C:\program files (x86)\common files\system\msadc"

    If (test-path $chkdir)
    {
        takeown /f "c:\program files\common files\system\msadc" /A /R
        icacls "C:\program files\common files\system\msadc" /grant administrators:F /t /c
        remove-item "C:\program files\common files\system\msadc" -recurse
    }
    Else
    {
        Write-log -msg "$chkdir does not exist, no further action necessary."
    }
    If (test-path $chkdir2)
    {
        takeown /f "c:\program files (x86)\common files\system\msadc" /A /R
        icacls "C:\program files (x86)\common files\system\msadc" /grant administrators:F /t /c
        remove-item "C:\program files (x86)\common files\system\msadc" -recurse
    }
    Else
    {
        Write-log -msg "$chkdir2 does not exist, no further action necessary."
    }

       
    write-log -msg "Configuring for IISW-SV-000102 / V-76681"
    Set-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -Filter "system.applicationHost/sites/sitedefaults/logfile" -name "logExtFileFlags" -value "Date,Time,ClientIP,UserName,ServerIP,Method,UriStem,UriQuery,HttpStatus,Win32Status,TimeTaken,ServerPort,UserAgent,Referer,HttpSubStatus" -ea Stop

    write-log -msg "Configuring for IISW-SV-000103, IISW-SI-000206 / V-76683, V-76785"
    Set-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -Filter "system.applicationHost/sites/sitedefaults/logfile" -name "logtargetW3C" -value "File,ETW" -ea Stop

    write-log -msg "Configuring for IISW-SV-000110 / V-76687"
    If (!(Get-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -filter system.applicationHost/sites/siteDefaults/logFile/CustomFields -name collection[logfieldname="reqheadconnec"]))
    {    
        Add-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -filter system.applicationHost/sites/siteDefaults/logFile/CustomFields -name "." -value @{logFieldName='ReqHeadConnec';sourceName='Connection';sourceType='RequestHeader'}
    }

    If (!(Get-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -filter system.applicationHost/sites/siteDefaults/logFile/CustomFields -name collection[logfieldname="ReqHeadWarn"]))
    {
        Add-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -filter system.applicationHost/sites/siteDefaults/logFile/CustomFields -name "." -value @{logFieldName='ReqHeadWarn';sourceName='Warning';sourceType='RequestHeader'}
    }
    
    # STIG v1r3 removes the below requiremnt for "HTTP_Connection"
    #If (!(Get-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -filter system.applicationHost/sites/siteDefaults/logFile/CustomFields -name collection[logfieldname="ServVarhttpconnec"]))
    #{
    #    Add-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -filter system.applicationHost/sites/siteDefaults/logFile/CustomFields -name "." -value @{logFieldName='ServVarhttpconnec';sourceName='HTTP_CONNECTION';sourceType='ServerVariable'}
    #}

    write-log -msg "Configuring for IISW-SV-000111 / V-76689"
    If (!(Get-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -filter system.applicationHost/sites/siteDefaults/logFile/CustomFields -name collection[logfieldname="ReqHeadUagent"]))
    {
    Add-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -filter system.applicationHost/sites/siteDefaults/logFile/CustomFields -name "." -value @{logFieldName='ReqHeadUagent';sourceName='User-Agent';sourceType='RequestHeader'}
    }
    If (!(Get-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -filter system.applicationHost/sites/siteDefaults/logFile/CustomFields -name collection[logfieldname="ReqHeadAuth"]))
    {
    Add-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -filter system.applicationHost/sites/siteDefaults/logFile/CustomFields -name "." -value @{logFieldName='ReqHeadAuth';sourceName='Authorization';sourceType='RequestHeader'}
    }
    If (!(Get-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -filter system.applicationHost/sites/siteDefaults/logFile/CustomFields -name collection[logfieldname="ResHeadCont-Type"]))
    {
    Add-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -filter system.applicationHost/sites/siteDefaults/logFile/CustomFields -name "." -value @{logFieldName='ResHeadCont-Type';sourceName='Content-Type';sourceType='ResponseHeader'}
    }
    # STIG v1r3 removes the HTTP_USER_AGENT requirement from the check
    #If (!(Get-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -filter system.applicationHost/sites/siteDefaults/logFile/CustomFields -name collection[logfieldname="ServVarhttpuAgent"]))
    #{
    #Add-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -filter system.applicationHost/sites/siteDefaults/logFile/CustomFields -name "." -value @{logFieldName='ServVarhttpuAgent';sourceName='HTTP_USER_AGENT';sourceType='ServerVariable'}
    #}
    
    write-log -msg "Configuring for IISW-SV-000124, IISW-SI-000214 / V-76711,V-76797"
    $mime = Get-WebConfigurationProperty -filter "//staticContent/mimeMap" -Name fileExtension | where{$_.value -eq '.bat' -or $_.value -eq '.com' -or $_.value -eq '.csh' -or $_.value -eq '.dll' -or $_.value -eq '.exe'}
    Foreach ($m in $mime.value)
        {
        Remove-WebConfigurationProperty -filter system.webServer/staticContent -Name "." -AtElement @{fileExtension=$m}
        }
        
    write-log -msg "Configuring for IISW-SV-000133-135 / V-76723, V-76725, V-76727 Also note this setting flows to each website and meets the requirement for V-76777"
    Set-WebConfigurationProperty -filter /system.web/sessionState -PSPath "MACHINE/WEBROOT" -name cookieless -value 'UseCookies' -ea Stop
    Set-WebConfigurationProperty -filter /system.web/sessionState -PSPath "MACHINE/WEBROOT" -name regenerateExpiredSessionId -value 'True' -ea Stop

    write-log -msg "Configuring for IISW-SV-000137 / V-76731"
    Set-WebConfigurationProperty -filter /system.web/machineKey -PSPath "MACHINE/WEBROOT" -name validation -value 'HMACSHA256' -ea Stop

    write-log -msg "Configuring for IISW-SV-000138 / V-76733"
    Set-WebConfigurationProperty -filter /system.webServer/directoryBrowse -PSPath "MACHINE/WEBROOT/APPHOST" -name enabled -value 'False' -ea Stop

    write-log -msg "Configuring for IISW-SV-000152 / V-76757"
    Set-WebConfigurationProperty -filter /system.webServer/asp/session -PSPath "MACHINE/WEBROOT/APPHOST" -name keepSessionIdSecure -value 'True' -ea Stop

    write-log -msg "Testing (see log for results) for IISW-SV-000157 / V-76767"
    $reg = Get-ItemProperty -path "HKCR:\CLSID\{0D43FE01-F093-11CF-8940-00A0C9054228}"
    If ($reg -ne $nul)
        {
        write-log -warn "This system has the File System Object enabled. If the solution on this system does not need the FSO run regsvr32 scrrun.dll /u to unregister. You will first need to change ownershipr on two registry keys
        to .\Administrators and add Full Control permission to .\Administrators. the keys are: HKCR:\CLSID\{0D43FE01-F093-11CF-8940-00A0C9054228} and HKCR:\Typelib\{420B2830-E718-11CF-893D-00A0C9054228}\1.0\0\win32
        please ensure you revert permissions and ownership back after unregistering"
        }
     
     write-log -msg "Configuring for IISW-SV-000158 / V-76769"
     Set-WebConfigurationProperty -filter /system.webserver/security/isapiCgiRestriction -PSPath "MACHINE/WEBROOT/APPHOST" -name notListedCgisAllowed -value 'False' -ea stop
     Set-WebConfigurationProperty -filter /system.webserver/security/isapiCgiRestriction -PSPath "MACHINE/WEBROOT/APPHOST" -name notListedIsapisAllowed -value 'False' -ea stop

     write-log -msg "Configuring for IISW-SV-000159 / V-76771"
     Clear-WebConfiguration -Filter /system.webserver/security/authorization -PSPath "MACHINE/WEBROOT/APPHOST"
     If (!(Get-WebConfigurationProperty -filter system.webserver/security/authorization -pspath MACHINE/WEBROOT/APPHOST -name collection[roles="Administrators"]))
     {
     Add-WebConfiguration -Filter /system.webserver/security/authorization -PSPath "MACHINE/WEBROOT/APPHOST" -Value @{accesstype="Allow"; roles="Administrators"} -ea stop
     }

#END IIS 8.5 Server STIG Items


#BEGIN IIS 8.5 Site STIG Items
<#Listing IIS 8.5 Site STIG Items not included in script as they are manual checks or vary greatly for implementations, or will be re-evaluated in next release of script
IISW-SI-000200/ V-76773  IISW-SI-000204/ V-76781
IISW-SI-000208/ V-76787  IISW-SI-000212/ V-76793
IISW-SI-000213/ V-76795  IISW-SI-000215/ V-76799
IISW-SI-000216/ V-76801  IISW-SI-000217/ V-76803
IISW-SI-000218/ V-76805  IISW-SI-000219/ V-76807
IISW-SI-000221/ V-76811  IISW-SI-000224/ V-76815
IISW-SI-000230/ V-76827  IISW-SI-000232/ V-76831
IISW-SI-000237/ V-76843  IISW-SI-000239/ V-76847
IISW-SI-000241/ V-76849  IISW-SI-000249/ V-76861
IISW-SI-000260/ V-76883  IISW-SI-000261/ V-76885
IISW-SI-000262/ V-76887  IISW-SI-000263/ V-76889
IISW-SI-000264/ V-76891
#>
     write-log -msg "Configuring for IISW-SI-000201 / V-76775"
     Set-WebConfigurationProperty -filter /system.web/sessionState -PSPath "MACHINE/WEBROOT" -name mode -value 'InProc' -ea Stop
     
     write-log -msg "Configuring for IISW-SI-000203,242,249 / V-76779,V-76851,V-76861 This is open finding as it should be 'SslRequireCert but that setting breaks most management websites within System Center Products"
     Set-WebConfigurationProperty -filter /system.webServer/security/access -name sslFlags -value 'Ssl,SslNegotiateCert,Ssl128' -PSPath "MACHINE/WEBROOT/APPHOST" -ea Stop

    # This is set in Server section write-log -msg "Configuring for IISW-SI-000206 / V-76785"
    # Set-WebConfigurationProperty -pspath 'machine/webroot/apphost' -filter "system.applicationhost/sites/sitedefaults/logfile" -name "logtargetW3C" -value "File,ETW"

     write-log -msg "Checking for IISW-SI-000217 / V-76803"
     $webDAV = Get-WindowsFeature | where {$_.name -eq "web-DAV-Publishing"}
     if(($webDAV -ne $null) -and (($webDAV.Installstate -eq "Installed")) -or ($webDAV.Installstate -eq "InstallPending"))
     {
         write-log -warn "The system has WebDAV Publishing enabled which is a CAT II vulnerability. Please ensure the solution requires WebDAV Publishing or remove the installed Windows feature."
     }

     write-log -msg "Configuring for IISW-SV-000223 / V-76813"
     Set-WebConfigurationProperty -filter /system.web/sessionState -PSPath "MACHINE/WEBROOT" -name mode -value 'InProc' -ea Stop

     write-log -msg "Configuring for IISW-SI-000225 / V-76817"
     Set-WebConfigurationProperty -filter /system.webServer/security/requestFiltering/requestLimits -PSPath "MACHINE/WEBROOT/APPHOST" -name maxUrl -value 4096 -ea Stop

     write-log -msg "Configuring for IISW-SI-000226 / V-76819"
     Set-WebConfigurationProperty -filter /system.webServer/security/requestFiltering/requestLimits -PSPath "MACHINE/WEBROOT/APPHOST" -name maxAllowedContentLength -value 30000000 -ea Stop

     write-log -msg "Configuring for IISW-SI-000227 / V-76821"
     Set-WebConfigurationProperty -filter /system.webServer/security/requestFiltering/requestLimits -PSPath "MACHINE/WEBROOT/APPHOST" -name maxQueryString -value 2048 -ea Stop

     write-log -msg "Configuring for IISW-SI-000228 / V-76823"
     Set-WebConfigurationProperty -filter /system.webServer/security/requestFiltering -PSPath "MACHINE/WEBROOT/APPHOST" -name AllowHighBitCharacters -value False -ea Stop

     write-log -msg "Configuring for IISW-SI-000229 / V-76825"
     Set-WebConfigurationProperty -filter /system.webServer/security/requestFiltering -PSPath "MACHINE/WEBROOT/APPHOST" -name AllowDoubleEscaping -value False -ea Stop

     write-log -msg "Configuring for IISW-SI-000231 / V-76829"
     Set-WebConfigurationProperty -filter /system.webServer/directoryBrowse -PSPath "MACHINE/WEBROOT/APPHOST" -name enabled -value False -ea Stop
     
     write-log -msg "Configuring for IISW-SI-000233 / V-76835"
     Set-WebConfigurationProperty -filter /system.webServer/httpErrors -PSPath "MACHINE/WEBROOT/APPHOST" -name errorMode -value DetailedLocalOnly -ea Stop

     write-log -msg "Configuring for IISW-SI-000234 / V-76837"
     Set-WebConfigurationProperty -filter /system.web/compilation -PSPath "MACHINE/WEBROOT" -name debug -value False -ea Stop

     write-log -msg "Configuring for IISW-SI-000235 / V-76839"
     Set-WebConfigurationProperty -filter /system.applicationHost/applicationPools/applicationPoolDefaults/processModel -PSPath "MACHINE/WEBROOT/APPHOST" -name idleTimeout -value 00:20:00 -ea Stop

     write-log -msg "Configuring for IISW-SI-000236 / V-76841"
     Set-WebConfigurationProperty -filter /system.web/sessionState -PSPath "MACHINE/WEBROOT" -name timeout -value 00:20:00 -ea Stop


    write-log -msg "Configuring for IISW-SI-000236 / V-76841"
    write-log -msg "The following commands will compress the IIs log directory and all log files contained within, if this is not desired please comment the following lines"
    $logpath = get-WebConfigurationProperty -pspath MACHINE/WEBROOT/APPHOST -Filter "system.applicationHost/sites/sitedefaults/logfile" -name Directory
    $logdirectory = $logpath.Value
    $Compress = "compact.exe /c /s:$logdirectory"
    CMD /C $Compress

    write-log -msg "Configuring for IISW-SI-000246 / V-76859"
    Set-WebConfigurationProperty -filter /system.web/httpCookies -PSPath "MACHINE/WEBROOT" -name requireSSL -value 'True' -ea Stop
    Set-WebConfigurationProperty -filter /system.web/sessionState -PSPath "MACHINE/WEBROOT" -name compressionEnabled -value 'False' -ea Stop
    
    write-log -msg "Configuring for IISW-SI-000235,251-259 / V-76839,V-76865,V-76867,V-76869,V-76871,V-76873,V-76875,V-76877,V-76879,V-76881"
    $apppools = Get-ChildItem -path IIS:\AppPools
    Foreach ($a in $apppools.name)
    {
        Set-ItemProperty "IIS:\AppPools\$a" -name "processModel" -Value @{idleTimeout="00:20:00";pingingEnabled="True"} -ea Stop
        #Setting some arbitrary values on next line for STIG compliance, please adjust for your environment
        Set-ItemProperty "IIS:\AppPools\$a" -name "recycling.periodicRestart" -value @{requests=250000;memory=2097152;privateMemory=2097152} -ea Stop
        Set-ItemProperty "IIS:\AppPools\$a" -name "recycling" -value @{logEventOnRecycle="Time,Schedule,Memory,PrivateMemory"} -ea Stop
        Set-ItemProperty "IIS:\AppPools\$a" -name "queueLength" -Value 1000 -ea Stop
        Set-ItemProperty "IIS:\AppPools\$a" -name "failure" -Value @{rapidFailProtection="True";rapidFailProtectionInterval="00:05:00"} -ea Stop
        [string] $NumberofApplications = (Get-WebConfigurationProperty "/system.applicationHost/sites/site/application[@applicationPool='$a']" "machine/webroot/apphost" -name path).Count
        If ($NumberofApplications -gt 1)
        {
            #Write-log -msg "AppPool name: $a has $NumberofApplications applications"
            Write-host "$a has more than 1 Application, this is an open finding!"
        }
    }
    
# The following command unlocks the asp section so it may be configured without error. The section will be locked again later in the script.
Set-WebConfiguration -filter /system.webServer/asp -PSPath "MACHINE/WEBROOT/APPHOST" -metadata overrideMode -value Allow -ea Stop
Set-WebConfiguration -filter /system.webServer/security/access -PSPath "MACHINE/WEBROOT/APPHOST" -metadata overrideMode -value Allow -ea Stop

write-log -msg "Configuring for IISW-SI-000225-229,230,233-235,242,244,246,249 / V-76817,V-76819,V-76821,V-76823,V-76825,V-76829,V-76835,V-76837,V-76839,V-76851,V-76855,V-76859,V-76861"
    Foreach ($w in $websites.name)
    {
        Set-WebConfigurationProperty -filter /system.webServer/security/requestFiltering/requestLimits -PSPath "MACHINE/WEBROOT/APPHOST/$w" -name maxUrl -value 4096 -ea Stop
        Set-WebConfigurationProperty -filter /system.webServer/security/requestFiltering/requestLimits -PSPath "MACHINE/WEBROOT/APPHOST/$w" -name maxAllowedContentLength -value 30000000 -ea Stop
        Set-WebConfigurationProperty -filter /system.webServer/security/requestFiltering/requestLimits -PSPath "MACHINE/WEBROOT/APPHOST/$w" -name maxQueryString -value 2048 -ea Stop
        Set-WebConfigurationProperty -filter /system.webServer/security/requestFiltering -PSPath "MACHINE/WEBROOT/APPHOST/$w" -name AllowHighBitCharacters -value False -ea Stop
        Set-WebConfigurationProperty -filter /system.webServer/security/requestFiltering -PSPath "MACHINE/WEBROOT/APPHOST/$w" -name AllowDoubleEscaping -value False -ea Stop
        Set-WebConfigurationProperty -filter /system.webServer/directoryBrowse -PSPath "MACHINE/WEBROOT/APPHOST/$w" -name enabled -value False -ea Stop
        Set-WebConfigurationProperty -filter /system.webServer/httpErrors -PSPath "MACHINE/WEBROOT/APPHOST/$w" -name errorMode -value DetailedLocalOnly -ea Stop
        Set-WebConfigurationProperty -filter /system.web/compilation -PSPath "MACHINE/WEBROOT/APPHOST/$w" -name debug -value False -ea Stop
        Set-WebConfigurationProperty -filter /system.web/sessionState -PSPath "MACHINE/WEBROOT/APPHOST/$w" -name timeout -value 00:20:00 -ea Stop
        Set-WebConfigurationProperty -filter /system.webServer/asp/session -PSPath "MACHINE/WEBROOT/APPHOST/$w" -name keepSessionIdSecure -value 'True' -ea Stop
        Set-WebConfigurationProperty -filter /system.web/httpCookies -PSPath "MACHINE/WEBROOT/APPHOST/$w" -name requireSSL -value 'True' -ea Stop
        Set-WebConfigurationProperty -filter /system.web/sessionState -PSPath "MACHINE/WEBROOT/APPHOST/$w" -name compressionEnabled -value 'False' -ea Stop
        Set-WebConfigurationProperty -filter /system.web/httpCookies -PSPath "MACHINE/WEBROOT/APPHOST/$w" -name httpOnlyCookies -value 'True' -ea Stop
        Set-WebConfigurationProperty -filter /system.web/httpCookies -PSPath "MACHINE/WEBROOT/APPHOST/$w" -name requireSSL -value 'True' -ea Stop
        Set-WebConfigurationProperty -filter /system.webServer/security/access -name sslFlags -value 'Ssl,SslNegotiateCert,Ssl128' -PSPath "MACHINE/WEBROOT/APPHOST/$w" -ea Stop
        Clear-WebConfiguration -Filter "/system.web/authorization/allow[@users='*' and @roles='' and @verbs='']" -PSPath "MACHINE/WEBROOT/APPHOST/$w" -ea stop
        Add-WebConfiguration -Filter /system.web/authorization -Value @{accesstype = "Allow";Users = "*"} -PSPath "MACHINE/WEBROOT/APPHOST/$w" -ea stop
    }

    # The following command locks the asp section to return to correct state. The section was previously unlocked earlier in the script.
    Set-WebConfiguration -filter /system.webServer/asp -PSPath "MACHINE/WEBROOT/APPHOST" -metadata overrideMode -value Deny -ea Stop
        
    write-log -msg "Configuring for IISW-SV-000153,154 / V-76759 & V-76761 (Enabling TLS 1.1 & TLS 1.2)"
    $newkey = (get-item HKLM:\).OpenSubKey("SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols", $true)
    $newkey.CreateSubKey('TLS 1.1')
    $newkey.CreateSubKey('TLS 1.2')
    $newkey.Close()
    $newkey = (get-item HKLM:\).OpenSubKey("SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1", $true)
    $newkey.CreateSubKey('Client')
    $newkey.CreateSubKey('Server')
    $newkey.Close()
    $newkey = (get-item HKLM:\).OpenSubKey("SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2", $true)
    $newkey.CreateSubKey('Client')
    $newkey.CreateSubKey('Server')
    $newkey.Close()
    
    New-ItemProperty -Path "HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name DisabledByDefault -PropertyType DWORD -Value 1 -ea SilentlyContinue
    New-ItemProperty -Path "HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name DisabledByDefault -PropertyType DWORD -Value 0 -ea SilentlyContinue
    New-ItemProperty -Path "HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name DisabledByDefault -PropertyType DWORD -Value 0 -ea SilentlyContinue
    New-ItemProperty -Path "HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name Enabled -PropertyType DWORD -Value 0 -ea SilentlyContinue
    New-ItemProperty -Path "HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name Enabled -PropertyType DWORD -Value 1 -ea SilentlyContinue
    New-ItemProperty -Path "HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name Enabled -PropertyType DWORD -Value 1 -ea SilentlyContinue
}

catch
{
    write-host ""
    write-host "An error has occurred! Detail to follow." -foregroundcolor red
    write-host ""
    do 
    {
        $answer = read-host "Do you want to restore IIs configuration? (Yes/No)"
    }
    until ("yes","no" -contains $answer)

    if ($answer -eq "Yes")
    {
        Restore-WebConfiguration -name "$backupname" -ea SilentlyContinue
        write-host "IIs configuration "$backupname" restored." -ForegroundColor yellow
    }
    Else
    {
         write-host "IIs configuration not restored." -ForegroundColor yellow
    }

    write-log -terminate $_
  
}


# Run iisreset for settings to take effect
write-log -msg "Performing an IISReset for changes to take effect"
iisreset
write-log -msg ""
write-log -msg "IIS 8.5 Hardening Script complete - Version $version"

<# Section to change Administrators permissions on log directories from FC to Read. Use to meet IISW-SI-000212,213 / V-76793, V-76795 Use at your own risk!
$sysdrv = $env:systemdrive
$logdir = Get-WebConfigurationProperty -filter system.applicationhost/sites/sitedefaults/logfile -name "directory"
$logdir = $logdir.value.TrimStart("%SystemDrive%")
$logdir = $sysdrv + $logdir

$dirs = get-childitem $logdir

Foreach ($d in $dirs.name)
    {
    $dir = $logdir + "\" + $d
    icacls $dir /remove administrators /T
    icacls $dir /grant:r administrators:R /t /c
    }
    #>