<#
.SYNOPSIS
Creates or removes ACL to block SYSTEM access to print spooler directory in response to CVE 2021 34527.

.DESCRIPTION
Creates or removes ACL to block SYSTEM access to print spooler directory in response to CVE 2021 34527.

.PARAMETER Logpath
If defined, will use this location to log before and after ACL change. 
Will output two txt files. One with the current ACL prior to making changes and another one with the ACL information after the ACL change. 
Output is raw data in json format and can be viewed using 'Get-Content -Raw <Path> | ConvertFrom-Json'

.PARAMETER AddACL
Adds the ACL to block SYSTEM access to print spooler directory

.PARAMETER RemoveACL
Removes the ACL to block SYSTEM access to print spooler directory

.PARAMETER OutError
If defined, will output 'Failed' on failure.

.PARAMETER OutSuccess
If defined, will output 'Success' on success.

.PARAMETER OutResult
If defined, will output 'Success' on success and 'Success' on success.

.PARAMETER CheckStatus
If defined, will check the status of the ACL. Use OutResult to display output or LogPath to save output.

.EXAMPLE
PrintNightmare-GoAway -Logpath C:\PSLogFolder -OutResult -AddACL
Logs the output to C:\PSLogFolder, adds the ACL to block SYSTEM access to print spooler directory and outputs the result

.EXAMPLE
PrintNightmare-GoAway -Logpath C:\PSLogFolder -OutResult -RemoveACL
Logs the output to C:\PSLogFolder, removes the ACL to block SYSTEM access to print spooler directory and outputs the result

.EXAMPLE
PrintNightmare-GoAway -AddACL 
Adds the ACL to block SYSTEM access to print spooler directory

.NOTES
Source of script: https://blog.truesec.com/2021/06/30/fix-for-printnightmare-cve-2021-1675-exploit-to-keep-your-print-servers-running-while-a-patch-is-not-available/ 
Created by Chaim Black at Intrust IT on 7/2/2021. https://www.intrust-it.com/
Complete testing on all operating systems has NOT been done on this script yet, so run this at your own risk and further research it.

Update: Updated ACL path per Fabio Viggiani on blog post thanks to _Dadministrator_ to avoid errors when running this as SYSTEM.
#>
function PrintNightmare-GoAway {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [String]$Logpath,
        [Parameter()]
        [Switch]$AddACL,
        [Parameter()]
        [Switch]$RemoveACL,
        [Parameter()]
        [Switch]$OutError,
        [Parameter()]
        [Switch]$OutSuccess,
        [Parameter()]
        [Switch]$OutResult,
        [Parameter()]
        [Switch]$CheckStatus
    )

    if($AddACL -and $RemoveACL) {
        Write-Host "Error: Cannot have both AddACL and RemoveACL together." -ForegroundColor Red
        Break
    }

    if ($Logpath) {
        $date = (get-date).toString("yyyy-MM-dd hh-mm-ss tt")

        If (!(test-path $Logpath)) {
            New-Item -ItemType Directory -Force -Path $Logpath | Out-Null
        }

        $LogFileOldACL     = $Logpath + '\' + $date + ' - OldACL.json'
        $LogFileNewACL     = $Logpath + '\' + $date + ' - NewACL.json'
        $LogFileCurrentACL = $Logpath + '\' + $date + ' - CurrentACL.json'
    }


    if ($AddACL) {
        $Path = "C:\Windows\System32\spool\drivers"
        $Acl = (Get-Item $Path).GetAccessControl('Access')
        if ($Logpath) {
           $Acl | Select-object * |  ConvertTo-Json -Depth 100 | Out-File $LogFileOldACL 
        }
        $Ar = New-Object  System.Security.AccessControl.FileSystemAccessRule("System", "Modify", "ContainerInherit, ObjectInherit", "None", "Deny")
        $Acl.AddAccessRule($Ar) | Out-Null
        Set-Acl $Path $Acl

        #Verify
        $FixACL = Get-Acl "C:\Windows\System32\spool\drivers"
        if ($Logpath) {
           $FixACL | Select-object * |  ConvertTo-Json -Depth 100 | Out-File $LogFileNewACL
        }
        
        if ($OutError -or $OutSuccess -or $OutResult) {
            $VerifyACL = $FixACL.AccessToString[0..32] -join ''

            if ($VerifyACL -like "*NT AUTHORITY\SYSTEM Deny  Modify*") {
                $Result = 'Success'
            }
            Else {
                $Result = 'Failed'
            }

            if ($OutResult) {$Result}

            if ($OutError) {
                if ($Result -like "Failed" ){$Result}
            }

            if ($OutSuccess) {
                if ($Result -like "Success") {$Result}
            }
        }
    }

    if ($RemoveACL) {
        $Path = "C:\Windows\System32\spool\drivers"
        $Acl = (Get-Item $Path).GetAccessControl('Access')
        if ($Logpath) {
           $Acl | Select-object * |  ConvertTo-Json -Depth 100 | Out-File $LogFileOldACL 
        }
        $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("System", "Modify", "ContainerInherit, ObjectInherit", "None", "Deny")
        $Acl.RemoveAccessRule($Ar) | Out-Null
        Set-Acl $Path $Acl
        
        #Verify
        $FixACL = (Get-Item $Path).GetAccessControl('Access')
        if ($Logpath) {
           $FixACL | Select-object * |  ConvertTo-Json -Depth 100 | Out-File $LogFileNewACL
        }
        
        if ($OutError -or $OutSuccess -or $OutResult) {
            $VerifyACL = $FixACL.AccessToString[0..32] -join ''

            if ($VerifyACL -notlike "*NT AUTHORITY\SYSTEM Deny  Modify*") {
                $Result = 'Success'
            }
            Else {
                $Result = 'Failed'
            }

            if ($OutResult) {$Result}

            if ($OutError) {
                if ($Result -like "Failed" ){$Result}
            }

            if ($OutSuccess) {
                if ($Result -like "Success") {$Result}
            }
        }
    }

    if ($CheckStatus) {
        $Path = "C:\Windows\System32\spool\drivers"
        $Acl = (Get-Item $Path).GetAccessControl('Access')
        if ($Logpath) {
           $Acl | Select-object * |  ConvertTo-Json -Depth 100 | Out-File $LogFileCurrentACL 
        }
        
        if ($OutResult) {
            $VerifyACL = $ACL.AccessToString[0..32] -join ''

            if ($VerifyACL -like "*NT AUTHORITY\SYSTEM Deny  Modify*") {
                $Result = 'ACL Applied'
            }
            Else {
                $Result = 'ACL Not Applied'
            }

            if ($OutResult) {$Result}
        }
    }
}