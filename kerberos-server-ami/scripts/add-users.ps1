$user=$Env:ADMIN
$user_pwd=$Env:ADMIN_PWD
Write-Host "adding user: [$user] with [$user_pwd] in groups: 'Administrators'"

net user $user $user_pwd /add /y
net localgroup administrators $user /add
