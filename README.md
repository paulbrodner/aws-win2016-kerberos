# About
Build automatically a new Kerbesos Windows Server using a custom [AD DS](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/ad-ds-getting-started) and [DNS](https://docs.microsoft.com/en-us/windows-server/networking/dns/dns-top) in AWS.

And a Windows client machine added in domain for testing purposes.

### Prerequisites
> Note, that I am NOT creating new VPC with Subnet or genetate new key-pairs. This solution assumes you already have those created in your AWS account. 
> custom configuration can be tweeked directly from [kerberos-environment/terraform.tfvars](./kerberos-environment/terraform.tfvars)

* initialize terraform under `kerberos-environment` folder

```
$ cd kerberos-environment
$ terraform init
```

### Usage
> run `make` to see help messages

#### a) build the custom Kerberos Server as AMI
> custom configuration can be tweeked directly on  [settings.json](./settings.json) file. 

```
$ make build-server
```

#### b) start the Kerberos Server using AMI
> follow the online guidelines when prompted

```
$ make start-server AMI_ID=<use-the-id-of-the-AMI-created-previous>
```
> you can use the following login credentials to login remotely to client machine (replacing Format with values from [settings.json](./settings.json) )

| Field         | Format |
| ------------- | ------------- |
| Username      | `SERVER_ADMIN_USERNAME`  |
| Password      | `SERVER_ADMIN_PASSWORD` |

#####  `Trubleshooting`
> if somehow the scrip [files/setup-server.ps1](./kerberos-environment/files/setup-server.ps1) was not executed correctly (e.g. script c:\httpkerberos.keytab not found) you can log in remotely to the server and check the `C:\ProgramData\Amazon\EC2-Windows\Launch\Log\UserdataExecution.log`

> the actual script executed should be saved under: `C:\Windows\TEMP\UserScript.ps1` (run this script manually using [Windows PowerShell ISE](http://www.powertheshell.com/isesteroids/) as administrator.

#### c) start the Kerberos Client
> this will start the Windows client machine that will be added in domain, in the server that we started on the previous step

> follow [this guide](https://aws.amazon.com/premiumsupport/knowledge-center/retrieve-windows-admin-password/) to retrieve administrator's password to login remotely

```
$ make start-client
```

> you can use the following login credentials to login remotely to client machine (replacing Format with values from [settings.json](./settings.json) )

| Field         | Format |
| ------------- | ------------- |
| Username      | `SERVER_ADMIN_USERNAME`@`DOMAIN`.`HOSTED_ZONE`  |
| Password      | `SERVER_ADMIN_PASSWORD` |
| Username      | `KERBEROS_ADMIN_USERNAME`@`DOMAIN`.`HOSTED_ZONE`  |
| Password      | `KERBEROS_ADMIN_PASSWORD` |
| Username      | `KERBEROS_TEST_USERNAME`@`DOMAIN`.`HOSTED_ZONE`  |
| Password      | `KERBEROS_TEST_PASSWORD` |


#### d) cleanup everithing
> this will delete the kerberos server and windows machine, route53 created. It will NOT delete the AMI

```
$ make cleanup
```


#### Videos
| Name         | Description |
| ------------- | ------------- |
| [build-server-1.mp4](./videos/build-server-1.mp4)      | creating a new AMI with custom AD DNS values |
| [build-server-2.mp4](./videos/build-server-2.mp4)      | result of building a new AMI |
| [start-server-1.mp4](./videos/start-server-1.mp4)      | start the server usign the AMI created |
| [start-server-2.mp4](./videos/start-server-2.mp4)      | RDC to server started |
| [start-client-1.mp4](./videos/start-client-1.mp4)      | start a new client in domain and RDC to it |