resource "aws_instance" "eft_linux" {
  depends_on      = [aws_key_pair.key_pair]
  #count           = length(var.subnet_id)
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = ["${var.sg_id}"]
  subnet_id       = var.subnet_id[count.index]
  user_data       = data.template_file.linux_ec2.rendered

  tags = {
    Name        = "${var.tag_name}"
    Project     = "${var.project_name}"
    Client      = "${var.client_name}"
    Application = "${var.application_name}"
    Environment = "${var.environment_name}"
    OS          = "${var.linux_name}"
  }
}

resource "aws_key_pair" "key_pair" {
  key_name = var.key_name
  public_key = ""

  tags = {
    Name        = "${var.tag_name}"
    Project     = "${var.project_name}"
    Client      = "${var.client_name}"
    Application = "${var.application_name}"
    Environment = "${var.environment_name}"
    OS          = "${var.linux_name}"
  }
}
