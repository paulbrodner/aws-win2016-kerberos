variable "DOMAIN" {}

variable "HOSTED_ZONE" {}

variable "REGION" {
  default = "eu-west-1"
}

variable "SERVER_AMI" {
  description = "Which Kerberos AMI should we use to create new EC2 Instance"  
  default     = "to-be-provided"
}

variable "SERVER_ADMIN_USERNAME" {
  description = "What is the password of the server admin"  
  default     = "admin"
}

variable "SERVER_ADMIN_PASSWORD" {
  description = "What is the username of the server admin"  
  default     = "to-be-provided"
}

variable "KERBEROS_ADMIN_USERNAME" {
  description = "What is the administrator user for kerberos"  
  default     = "kerberosauth"
}

variable "KERBEROS_ADMIN_PASSWORD" {
  description = "What is the password for the administrator user for kerberos auth"  
  default     = "to-be-provided"
}

variable "KERBEROS_TEST_USERNAME" {
  description = "What is the test user for kerberos"  
  default     = "kerbtestuser"
}

variable "KERBEROS_TEST_PASSWORD" {
  description = "What is the password for the test user for kerberos auth"  
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

variable "VPC_ID" {
  description = "What is the existing VPC ID"
  default     = "to-be-provided"
}

variable "VPC_SECURITY_GROUP_ID" {
  description = "What is the existing VPC security group ID"
}

variable "SUBNET_ID" {
  description = "What is the existing subnet id in your VPC"
}



