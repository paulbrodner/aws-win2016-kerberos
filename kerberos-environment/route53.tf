data "aws_route53_zone" "hosted" {
  name = "${var.hosted_zone}"
}

resource "aws_route53_record" "domain" {
  zone_id = "${data.aws_route53_zone.hosted.zone_id}"
  name    = "${var.domain}.${var.hosted_zone}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.kerberos-server.private_ip}"]
}
