
resource "aws_instance" "kerberos-server" {
  ami                         = "${var.kerberos_server_ami}"
  key_name                    = "${var.key_name}"
  instance_type               = "t2.large"
  disable_api_termination     = "false"
  subnet_id                   = "${var.subnet_id}"
  vpc_security_group_ids      = ["${var.vpc_security_group_id}"]
  associate_public_ip_address = "true"
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "30"
    delete_on_termination = true
  }

  monitoring = false
  tags = {
    Name   = "${var.domain}-server"
    Author = "pbrodner"
    Tool   = "terraform"
  }

  user_data = "${file("scripts/setup-server.ps1")}"
}
