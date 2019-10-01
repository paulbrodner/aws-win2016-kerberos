$user=$Env:ADMIN
$user_pwd=$Env:ADMIN_PWD
Write-Host "adding user: [$user] with [$user_pwd] in administrator group"

net user $user $user_pwd /add /y
net localgroup administrators $user /add

#Set domain path on which users are created E.g "cn=Users,dc=alfresco,dc=com"
$DOMAIN="$Env:DOMAIN"
$HOSTED_ZONE="$Env:HOSTED_ZONE"
$DOMAINNAME = "$DOMAIN.$HOSTED_ZONE"
$DOMAIN_ARRAY = $DOMAINNAME.split('.')
$DOMAIN_PATH = “cn=Users"

foreach ($domcomp in $DOMAIN_ARRAY) {
   $DOMAIN_PATH = "$DOMAIN_PATH,dc=$domcomp"
}

#Create kerberos authentication user used for creating keytabs
Write-Host "Create kerberos authentication user: [$KERBAUTH]"

$KERBAUTH_PASSWORD = ConvertTo-SecureString $KERBAUTH_PWD -AsPlainText -Force
New-ADUser -Name $KERBAUTH -DisplayName “Kerberos Auth” -GivenName Kerberos -Surname Auth -TrustedForDelegation 1 -Path "$DOMAIN_PATH” -ChangePasswordAtLogon 0 -AccountPassword $KERBAUTH_PASSWORD -PasswordNeverExpires 1 -Enabled 1
Set-ADAccountControl -Identity $KERBAUTH -DoesNotRequirePreAuth:$true

#Create kerberos test user
Write-Host "Create kerberos authentication user to use in tests: [$KERBTEST]"

$KERBTEST_PASSWORD = ConvertTo-SecureString $KERBTEST_PWD -AsPlainText -Force
New-ADUser -Name $KERBTEST -DisplayName “Kerberos TestUser” -GivenName Kerberos -Surname TestUser -TrustedForDelegation 1 -Path "$DOMAIN_PATH” -ChangePasswordAtLogon 0 -AccountPassword $KERBTEST_PASSWORD -PasswordNeverExpires 1 -Enabled 1