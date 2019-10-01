$user_pwd="$Env:ADMIN_PWD"
$domain="$Env:DOMAIN"
$hosted_zone="$Env:HOSTED_ZONE"
$domainname="$domain.$hosted_zone"
$netbiosName = "$domain".ToUpper()

# make the computer discoverable
cmd.exe /c netsh advfirewall firewall set rule group="network discovery" new enable=yes

Write-Host "Start: installing Active Directory"
# install Active Directory 
Install-windowsfeature AD-domain-services -IncludeManagementTools

Write-Host "DONE: installing Active Directory"
Write-Host "Start: installing DNS: domainname: [$domainname], netbiosname: [$netbiosName]"

Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$false `
-SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "$user_pwd" -Force) `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName $domainname `
-DomainNetbiosName $netbiosName `
-ForestMode "WinThreshold" `
-InstallDns `
-LogPath "C:\Windows\NTDS" `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true

# TODO add here code for generating keys
Write-Host "DONE: installing DNS"