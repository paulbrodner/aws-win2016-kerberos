$user=$Env:ADMIN
$user_pwd=$Env:ADMIN_PWD
Write-Host "adding user: [$user] with [$user_pwd] in administrator group"

net user $user $user_pwd /add /y
net localgroup administrators $user /add
# adding user to Domain Adming - to be able to RDC
net group "Domain Admins" $user /add
