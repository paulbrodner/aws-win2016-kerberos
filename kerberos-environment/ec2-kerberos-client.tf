
resource "aws_instance" "kerberos-client" {
  ami                         = "${var.CLIENT_AMI}"
  key_name                    = "${var.KEY_PAIR_NAME}"
  instance_type               = "t2.large"
  disable_api_termination     = "false"
  subnet_id                   = "${var.SUBNET_ID}"
  vpc_security_group_ids      = ["${var.VPC_SECURITY_GROUP_ID}"]
  associate_public_ip_address = "true"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "30"
    delete_on_termination = true
  }

  monitoring = false
  tags = {
    Name   = "${var.DOMAIN}-client"
    Creator = "Platform-Services"
    Owner  = "Platform-Services"
    Department = "Engineering"
    Purpose = "SSO testing"
    NoAutomaticShutdown = "True"
    Production = "False"
    Tool   = "Terraform"
  }

  user_data = "${data.template_file.setup_client.rendered}"
}

data "template_file" "setup_client" {
  template = "${file("files/setup-client.ps1")}"
  vars = {
    SERVER_ADMIN_USERNAME   = "${var.SERVER_ADMIN_USERNAME}"
    SERVER_ADMIN_PASSWORD   = "${var.SERVER_ADMIN_PASSWORD}"    
    DOMAIN                  = "${var.DOMAIN}"
    HOSTED_ZONE             = "${var.HOSTED_ZONE}"    
  }
}

