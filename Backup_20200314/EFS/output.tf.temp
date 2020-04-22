output "efs_dns_name" {
  value = "${aws_efs_file_system.eft_efs.dns_name}"
}

output "efs_private_ip" {
  value = "${aws_efs_mount_target.eft-efs-mt[*].ip_address}"
}

output "linux_ec2_private_ip" {
  value = "${aws_instance.eft_linux[*].private_ip}"
}

output "linux_ec2_instance_id" {
  value = "${aws_instance.eft_linux[*].id}"
}

output "windows_ec2_private_ip" {
  value = "${aws_instance.eft_windows[*].private_ip}"
}

output "windows_ec2_instance_id" {
  value = "${aws_instance.eft_windows[*].id}"
}

/**
output "eft_linux_lb" {
  value = "${aws_lb.eft_linux_lb.dns_name}"
}

output "eft_windows_lb" {
  value = "${aws_lb.eft_windows_lb.dns_name}"
}
**/
