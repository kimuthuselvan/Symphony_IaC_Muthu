resource "aws_efs_file_system" "eft_efs" {
  creation_token   = "symphony_eft_prod_efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"

  lifecycle {
    prevent_destroy = true
  }
  
  tags = {
    Name    = "symphony_eft_prod_efs"
    Project = "${var.project_name}"
    Client  = "${var.client_name}"
    Application = "${var.application_name}"
    Environment = "${var.environment_name}"
  }
}

resource "aws_efs_mount_target" "eft-efs-mt" {
  count           = length(var.subnet_id)
  file_system_id  = aws_efs_file_system.eft_efs.id
  subnet_id       = var.subnet_id[count.index]
  security_groups = ["${var.sg_id}"]
}

