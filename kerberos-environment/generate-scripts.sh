#!/usr/bin/env bash
set -u

function strip_quotes
{     
    echo $1 |  sed -e 's/"//g' 
}

DOMAIN=$(strip_quotes $domain)
HOSTED_ZONE=$(strip_quotes $hosted_zone)
KERBEROS_CLIENT_USERNAME=$(strip_quotes $kerberos_client_username)
KERBEROS_CLIENT_PASSWORD=$(strip_quotes $kerberos_client_password)

# generate PowerShell script for defining AD
cat <<EOF > ./scripts/setup-server.ps1
<powershell>
\$privateIP=((ipconfig | findstr [0-9].\.)[0]).Split()[-1]
\$subnet=((ipconfig | findstr [0-9].\.)[1]).Split()[-1]
\$gw=((ipconfig | findstr [0-9].\.)[2]).Split()[-1]
\$dns=(netsh interface ip show dnsservers | findstr [0-9].\.).Split()[-1]

netsh interface ip set dns "Ethernet" static "127.0.0.1"
netsh interface ip add dns name="Ethernet" addr=\$dns index=2
netsh interface ip set address "Ethernet" static \$privateIP \$subnet \$gw

netsh advfirewall firewall set rule group=”network discovery” new enable=yes

</powershell>
EOF

# generating PowerShell script for configuring client 
cat <<EOF > ./scripts/setup-client.ps1
<powershell>
# add admin user
net user ${KERBEROS_CLIENT_USERNAME} ‘${KERBEROS_CLIENT_PASSWORD}’ /add /y
net localgroup administrators ${KERBEROS_CLIENT_USERNAME} /add

\$domain = "${DOMAIN}.${HOSTED_ZONE}"
# set DNS ip address
\$ping = New-Object System.Net.NetworkInformation.Ping
\$ip = \$(\$ping.Send(\$domain).Address).IPAddressToString

netsh dnsclient add dnsserver "Ethernet" \$ip 4

# add computer in domain
\$password = "${KERBEROS_CLIENT_PASSWORD}" | ConvertTo-SecureString -asPlainText -Force
\$username = "\$domain\admin" 
\$credential = New-Object System.Management.Automation.PSCredential(\$username,\$password)

Add-Computer -DomainName \$domain -Credential \$credential -Restart

Write-Host "Start: installing Chrome  browser"
Invoke-WebRequest "http://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile \$env:TEMP\chrome_installer.exe; 
Start-Process -FilePath \$env:TEMP\chrome_installer.exe -Args "/silent /install" -Verb RunAs -Wait; 
Remove-Item \$env:TEMP\chrome_installer.exe

Write-Host "Done: installing Chrome  browser"
</powershell>
EOF
