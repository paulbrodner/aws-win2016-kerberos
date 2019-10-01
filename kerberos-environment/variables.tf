variable "domain" {}

variable "hosted_zone" {}

variable "region" {
  default = "eu-west-1"
}

variable "kerberos_client_username" {
  description = "This user will be added in Server and Client machines"
  default     = "admin"
}

variable "kerberos_client_password" {
  description = "This will be the password associated with kerberos_client_password"
  default     = "Alfresco!12346789"
}

variable "kerberos_server_ami" {
  description = "Which Kerberos AMI should we use to create new EC2 Instance"  
  default     = "to-be-provided"
}

variable "windows_client_ami" {
  description = "Which AMI should we use to create new Windows Server 2016 (using default value from region)"
  default     = "ami-09c6f606506004483"
}

variable "key_name" {
  description = "Which Key Pair should we use to access the Windows machine"
  default     = "ps-sso-kerberos"
}
variable "vpc_security_group_id" {
  description = "What is the existing VPC security group ID"
}

variable "subnet_id" {
  description = "What is the existing subnet id in your VPC"
}



