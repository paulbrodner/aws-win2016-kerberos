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
> custom configuration can be tweeked directly from [kerberos-server-ami/template.json](./kerberos-server-ami/template.json)
```
$ make build-ami
```

#### b) start the Kerberos Server using AMI
> follow the online guidelines when prompted

```
$ make start-server AMI_ID=`the-id-of-the-AMI-created`
```

#### c) start the Kerberos Client
> this will start the Windows client machine
> follow [this guide](https://aws.amazon.com/premiumsupport/knowledge-center/retrieve-windows-admin-password/) to retrieve administrator's password to login remotely

```
$ make start-client
```

#### d) cleanup everithing
> this will delete the kerberos server and windows machine, route53 created. It will NOT delete the AMI

```
$ make cleanup
```
