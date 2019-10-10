
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

  user_data = "${data.template_file.setup_server.rendered}"

  provisioner "local-exec" {
    command = "sleep 300"
  }
}

data "template_file" "setup_server" {
  template = "${file("files/setup-server.ps1")}"
  vars = {
    SERVER_ADMIN_USERNAME   = "${var.SERVER_ADMIN_USERNAME}"    
    DOMAIN                  = "${var.DOMAIN}"
    HOSTED_ZONE             = "${var.HOSTED_ZONE}"
    KERBEROS_ADMIN_USERNAME = "${var.KERBEROS_ADMIN_USERNAME}"
    KERBEROS_ADMIN_PASSWORD = "${var.KERBEROS_ADMIN_PASSWORD}"
    KERBEROS_TEST_USERNAME  = "${var.KERBEROS_TEST_USERNAME}"
    KERBEROS_TEST_PASSWORD  = "${var.KERBEROS_TEST_PASSWORD}"
    FQDN                    = "${var.FQDN}"
  }
}
