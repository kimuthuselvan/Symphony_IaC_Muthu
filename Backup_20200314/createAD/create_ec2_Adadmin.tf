
resource "aws_instance" "vm_adwriter" {
	disable_api_termination = false
	instance_type = var.vm_instance_type
	ami = var.vm_ami_id
	iam_instance_profile = aws_iam_instance_profile.instance_profile_adwriter.name
	subnet_id = var.subnet_ids[0]
        key_name  = var.key_name
        security_groups = [ var.security_group ]
        user_data = data.template_file.win-server.rendered
	root_block_device {
		volume_type = "gp2"
		volume_size = var.vm_disk_size
		delete_on_termination = true
	}
	#monitoring = true
        depends_on = [aws_directory_service_directory.my_simplead]
}


data "template_file" "win-server" {
  template = "${file("${var.user_data_file}")}"

  vars = {
    dns1 = "${join(",",aws_directory_service_directory.my_simplead.dns_ip_addresses)}"
  }
}


resource "aws_ssm_document" "myapp_dir_default_doc" {
	name  = "${var.short_name}-ssm-document"
	document_type = "Command"

	content = <<DOC
{
        "schemaVersion": "1.0",
        "description": "Join an instance to a domain",
        "runtimeConfig": {
           "aws:domainJoin": {
               "properties": {
                  "directoryId": "${aws_directory_service_directory.my_simplead.id}",
                  "directoryName": "${var.domain_name}",
                  "dnsIpAddresses": ${jsonencode(aws_directory_service_directory.my_simplead.dns_ip_addresses)}
               }
           }
        }
}
DOC
	depends_on = [aws_directory_service_directory.my_simplead]
}

resource "aws_ssm_association" "myapp_adwriter" {
	name = "${var.short_name}-ssm-document"
	instance_id = aws_instance.vm_adwriter.id
	depends_on = [aws_ssm_document.myapp_dir_default_doc, aws_instance.vm_adwriter]
}



## IAM policies

resource "aws_iam_instance_profile" "instance_profile_adwriter" {
  name  = "INSTANCE_PROFILE_ADWRITER"
  role = aws_iam_role.iam_role_adwriter.name
}

resource "aws_iam_role" "iam_role_adwriter" {
  name = "IAM_ROLE_ADWRITER"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "policy_allow_all_ssm" {
  name = "IAM_POLICY_ALLOW_ALL_SSM"
  role = aws_iam_role.iam_role_adwriter.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessToSSM",
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:ListAssociations",
                "ssm:GetDocument",
                "ssm:ListInstanceAssociations",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceInformation",
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply",
                "ds:CreateComputer",
                "ds:DescribeDirectories",
                "ec2:DescribeInstanceStatus"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}
