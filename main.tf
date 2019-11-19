module "instance_profile_bastion" {
  source  = "linux-place/instanceprofile/aws"
  version = "0.1.0"
  name   = var.bastion_profile_name
  policies = concat(
    [
      data.aws_iam_policy.AmazonEC2RoleforSSM.arn,
      data.aws_iam_policy.CloudWatchAgentAdminPolicy.arn,
    ],
    var.policies,
  )
  policy_count = length(
    concat(
      [
        data.aws_iam_policy.AmazonEC2RoleforSSM.arn,
        data.aws_iam_policy.CloudWatchAgentAdminPolicy.arn,
      ],
      var.policies,
    ),
  )
}

#Policy admin
data "aws_iam_policy" "CloudWatchAgentAdminPolicy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
}

# CloudWatchAgentServer
data "aws_iam_policy" "CloudWatchAgentServerPolicy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# SSM
data "aws_iam_policy" "AmazonEC2RoleforSSM" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_eip" "this_instance_ip" {
  instance = aws_instance.this_instance.id
  vpc      = true
}

# module "ami" {
#  source = "../ami"
#}

resource "aws_instance" "this_instance" {
  key_name                    = var.ssh_key_name
  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  iam_instance_profile        = module.instance_profile_bastion.role_name

  vpc_security_group_ids = [ module.bastion_host_sg.this_security_group_id ]
  subnet_id              = var.subnet_id

  root_block_device {
    volume_size = 15
  }

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
    var.bastion_tags,
  )
}


module "bastion_host_sg" {
  source = "terraform-aws-modules/security-group/aws"
  name        = "bastion-access"
  description = "Security group for Bastion Host"
  vpc_id      = var.vpc_id

  # Open for security group id (rule or from_port+to_port+protocol+description)
  ingress_with_cidr_blocks = var.allowed_cidr_blocks

  egress_with_cidr_blocks = [
    {
      cidr_blocks = "0.0.0.0/0"
      protocol    = "tcp"
      from_port   = 0
      to_port     = 65534
    },
    {
      cidr_blocks = "0.0.0.0/0"
      protocol    = "udp"
      from_port   = 0
      to_port     = 65534
    },
  ]
}
