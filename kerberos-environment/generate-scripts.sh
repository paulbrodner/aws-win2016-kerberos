#!/usr/bin/env bash
set -u

SETTINGS="${1:-../settings.json}"
# export all values from json as key=value in environment
set -x
$( cat ${SETTINGS} | jq -r 'keys[] as $k | "export \($k)=\(.[$k])"' )

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

# this user is already created and exist here
# we only need to add it to Domain Admins so we can remotely loggin with it
net group "Domain Admins" ${SERVER_ADMIN_USERNAME}"  /add

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

# disabling UAC
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'LocalAccountTokenFilterPolicy' -Value 1 -Force

Write-Host "Start: installing Chrome  browser"
Invoke-WebRequest "http://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile \$env:TEMP\chrome_installer.exe; 
Start-Process -FilePath \$env:TEMP\chrome_installer.exe -Args "/silent /install" -Verb RunAs -Wait; 
Remove-Item \$env:TEMP\chrome_installer.exe

Write-Host "Done: installing Chrome  browser"

Write-Host "START: applying Chrome Group Policy for Kerberos authentication"

# following DOCS: https://docs.alfresco.com/6.1/concepts/auth-kerberos-clientconfig.html
# we extracted only the files that we need from the zip and copy them to PolicyDefinitions  on client
\$admxRoot   = "https://raw.githubusercontent.com/paulbrodner/aws-win2016-kerberos/DEPLOY-844-group-policy/"
\$chromeAdmx = \$admxRoot + "kerberos-environment/scripts/admx/chrome.admx"
\$chromeAdml = \$admxRoot + "kerberos-environment/scripts/admx/en-US/chrome.adml"

Invoke-WebRequest \$chromeAdmx -OutFile C:\Windows\PolicyDefinitions\chrome.admx;
Invoke-WebRequest \$chromeAdml -OutFile C:\Windows\PolicyDefinitions\en-US\chrome.adml;

Write-Host  \$chromeAdmx;
gpupdate /force

# we also need to specify the wildcard of the Kerberos delegation server whitelist  (step 8. from docs above)
New-Item -Path "HKLM:\Software\Policies\Google"
New-Item -Path "HKLM:\Software\Policies\Google\Chrome"
New-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome" -PropertyType String  -Name AuthNegotiateDelegateWhitelist -Value "*.dev.alfresco.me"

Write-Host "DONE: applying Chrome Group Policy for Kerberos authentication"

# add computer in domain
\$password = "${SERVER_ADMIN_PASSWORD}" | ConvertTo-SecureString -asPlainText -Force
\$username = "\$domain\\${SERVER_ADMIN_USERNAME}" 
\$credential = New-Object System.Management.Automation.PSCredential(\$username,\$password)

Add-Computer -DomainName \$domain -Credential \$credential -Restart

</powershell>
EOF
