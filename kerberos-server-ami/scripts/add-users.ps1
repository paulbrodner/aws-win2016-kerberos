import-module activedirectory

$user=$Env:ADMIN
$user_pwd=$Env:ADMIN_PWD
$domain = "$Env:DOMAIN"
$hosted_zone = "$Env:HOSTED_ZONE"
$domainname = "$domain.$hosted_zone"
$domain_array = $domainname.split('.')
$domain_path = "cn=Users"
$kerbtest = "$Env:KERBTEST"
$kerbtest_pwd = "$Env:KERBTEST_PWD"
$kerbauth = "$Env:KERBAUTH"
$kerbauth_pwd = "$Env:KERBAUTH_PWD"
Write-Host "adding user: [$user] with [$user_pwd] in administrator group"

net user $user $user_pwd /add /y
net localgroup administrators $user /add

#Set domain path on which users are created E.g "cn=Users,dc=alfresco,dc=com"
foreach ($domcomp in $domain_array) {
   $domain_path = "$domain_path,dc=$domcomp"
}

#Create kerberos authentication user used for creating keytabs
Write-Host "Create kerberos authentication user: [$KERBAUTH]"
$kerbauth_pwd_secure = ConvertTo-SecureString $kerbauth_pwd -AsPlainText -Force
New-ADUser -Name $kerbauth -DisplayName "Kerberos Auth" -GivenName Kerberos -Surname Auth -TrustedForDelegation 1 -Path "$domain_path" -ChangePasswordAtLogon 0 -AccountPassword $kerbauth_pwd_secure -PasswordNeverExpires 1 -Enabled 1
Set-ADAccountControl -Identity $kerbauth -DoesNotRequirePreAuth:$true

#Create kerberos test user
Write-Host "Create kerberos authentication user to use in tests: [$kerbtest]"
$krbtest_pwd_secure = ConvertTo-SecureString $kerbtest_pwd -AsPlainText -Force
New-ADUser -Name $kerbtest -DisplayName "Kerberos TestUser" -GivenName Kerberos -Surname TestUser -TrustedForDelegation 1 -Path "$domain_path" -ChangePasswordAtLogon 0 -AccountPassword $krbtest_pwd_secure -PasswordNeverExpires 1 -Enabled 1