
resource "aws_instance" "kerberos-server" {
  ami                         = "${var.SERVER_AMI}"
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
    Name   = "${var.DOMAIN}-server"
    Author = "pbrodner"
    Tool   = "terraform"
  }

  user_data = "${file("scripts/setup-server.ps1")}"
}
