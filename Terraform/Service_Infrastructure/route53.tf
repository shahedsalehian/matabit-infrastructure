data "aws_route53_zone" "selected" {
  name         = "matabit.org."
  private_zone = false
}

resource "aws_route53_record" "alb-record-txt" {
  zone_id = "${data.aws_route53_zone.selected.id}" # Replace with your zone ID
  name    = "_acme-challenge.matabit.org." # Replace with your name/domain/subdomain
  type    = "TXT"
  ttl     = "60"
  records = ["UphA6dM4tFTvQ-4IEz3yT-LZHiqqKVcn3WP4m3MiqnQ"]
}
resource "aws_route53_record" "alb-record-www" {
  zone_id = "${data.aws_route53_zone.selected.id}" # Replace with your zone ID
  name    = "www.matabit.org" # Replace with your name/domain/subdomain
  type    = "A"
  ttl     = "60"
  records = ["${aws_lb.alb.dns_name}"]
}

resource "aws_route53_record" "alb-record-blog" {
  zone_id = "${data.aws_route53_zone.selected.id}" # Replace with your zone ID
  name    = "blog.matabit.org" # Replace with your name/domain/subdomain
  type    = "A"
  ttl     = "60"
  records = ["${aws_lb.alb.dns_name}"]
}

resource "aws_route53_record" "alb-record-apex" {
  zone_id = "${data.aws_route53_zone.selected.id}" # Replace with your zone ID
  name    = "matabit.org" # Replace with your name/domain/subdomain
  type    = "A"
  ttl     = "60"
  records = ["${aws_lb.alb.dns_name}"]
}
