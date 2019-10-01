output "kerberos-domain" {
  value = "${aws_route53_record.domain.name}"
}

output "kerberos-server-public-ip" {
  value = "${aws_instance.kerberos-server.public_ip}"
}

output "kerberos-client-public-ip" {
  value = "${aws_instance.kerberos-client.public_ip}"
}