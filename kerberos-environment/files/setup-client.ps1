<powershell>
Write-Host "Sucessfully setup network aaa"

# add admin user
net user admin ${SERVER_ADMIN_USERNAME} /add /y
net localgroup administrators kerberosauth /add

$domain = "${SERVER_HOSTNAME}.${DOMAIN}.${HOSTED_ZONE}"
# set DNS ip address
$ping = New-Object System.Net.NetworkInformation.Ping
$ip = $($ping.Send($domain).Address).IPAddressToString

netsh dnsclient add dnsserver "Ethernet" $ip 4

# disabling UAC
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'LocalAccountTokenFilterPolicy' -Value 1 -Force

Write-Host  "Start: installing Chrome  browser"
Invoke-WebRequest "http://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile $env:TEMP\chrome_installer.exe; 
Start-Process -FilePath $env:TEMP\chrome_installer.exe -Args "/silent /install" -Verb RunAs -Wait; 
Remove-Item $env:TEMP\chrome_installer.exe

Write-Host  "Done: installing Chrome  browser"

Write-Host  "START: applying Chrome Group Policy for Kerberos authentication"

# following DOCS: https://docs.alfresco.com/6.1/concepts/auth-kerberos-clientconfig.html
# we extracted only the files that we need from the zip and copy them to PolicyDefinitions  on client
$admxRoot   = "https://raw.githubusercontent.com/Alfresco/aws-win2016-kerberos/master/"
$chromeAdmx = $admxRoot + "kerberos-environment/files/admx/chrome.admx"
$chromeAdml = $admxRoot + "kerberos-environment/files/admx/en-US/chrome.adml"

Invoke-WebRequest $chromeAdmx -OutFile C:\Windows\PolicyDefinitions\chrome.admx;
Invoke-WebRequest $chromeAdml -OutFile C:\Windows\PolicyDefinitions\en-US\chrome.adml;

Write-Host  "Downloading: $chromeAdmx";
gpupdate /force

# we also need to specify the wildcard of the Kerberos delegation server whitelist  (step 8. from docs above)
New-Item -Path "HKLM:\Software\Policies\Google"
New-Item -Path "HKLM:\Software\Policies\Google\Chrome"
New-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome" -PropertyType String  -Name AuthNegotiateDelegateWhitelist -Value "*.dev.alfresco.me"

Write-Host  "DONE: applying Chrome Group Policy for Kerberos authentication"

# add computer in domain
$password = "${SERVER_ADMIN_PASSWORD}" | ConvertTo-SecureString -asPlainText -Force
$username = "$domain\${SERVER_ADMIN_USERNAME}" 
$credential = New-Object System.Management.Automation.PSCredential($username,$password)

Add-Computer -DomainName $domain -Credential $credential -Restart

</powershell>
