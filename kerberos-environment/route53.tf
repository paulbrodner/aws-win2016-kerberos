data "aws_route53_zone" "hosted" {
  name = "${var.HOSTED_ZONE}"
}

resource "aws_route53_record" "domain" {
  zone_id = "${data.aws_route53_zone.hosted.zone_id}"
  name    = "${var.DOMAIN}.${var.HOSTED_ZONE}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.kerberos-server.private_ip}"]
}
