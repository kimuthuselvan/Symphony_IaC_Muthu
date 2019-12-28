output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "default_sg_id" {
  value = "${aws_default_security_group.default.id}"
}

output "linux_web_sg_id" {
  value = "${aws_security_group.linux_web_sg}"
}

output "windows_web_sg_id" {
  value = "${aws_security_group.windows_web_sg}"
}

