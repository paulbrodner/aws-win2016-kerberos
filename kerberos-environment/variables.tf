variable "DOMAIN" {}

variable "HOSTED_ZONE" {}

variable "REGION" {
  default = "eu-west-1"
}

variable "SERVER_AMI" {
  description = "Which Kerberos AMI should we use to create new EC2 Instance"  
  default     = "to-be-provided"
}

variable "CLIENT_AMI" {
  description = "Which AMI should we use to create new Windows Server 2016 (using default value from region)"
  default     = "ami-09c6f606506004483"
}

variable "KEY_PAIR_NAME" {
  description = "Which Key Pair should we use to access the Windows machine"
  default     = "ps-sso-kerberos"
}
variable "VPC_SECURITY_GROUP_ID" {
  description = "What is the existing VPC security group ID"
}

variable "SUBNET_ID" {
  description = "What is the existing subnet id in your VPC"
}



