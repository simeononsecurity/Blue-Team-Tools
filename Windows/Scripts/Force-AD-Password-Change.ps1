#https://expert-advice.org/active-directory/force-users-change-active-directory-password-next-logon/
#get-aduser -Filter * -SearchBase "OU=Users,DC=example,DC=com" | set-aduser -ChangePasswordAtLogon $True
$ADuser = Get-ADUser $userID
If($ADuser)
{
Set-adaccountpassword $userID -reset -newpassword (ConvertTo-SecureString -AsPlainText $password -Force)
Set-aduser $userID -changepasswordatlogon $true
}