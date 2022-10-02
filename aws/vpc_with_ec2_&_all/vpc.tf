########################################
######    VPC
########################################
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.environment}-vpc"
    "Environment" = "${var.environment}"
  }
}


########################################
######    INTERNET GATEWAY
########################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]
  tags = {
    "Name" = "${var.environment}-igw"
    "Environment" = "${var.environment}"
  }
}




# ########################################
# ######    SECURITY GROUP
# ########################################
resource "aws_security_group" "sg" {

  name = "${var.environment}-demo-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = var.security_group_open_port[0]
    to_port   = var.security_group_open_port[1]
    protocol  = "tcp"
    description = "Allow workstation IP"
    cidr_blocks = [local.workstation_external_ip]   ## YOUR EXTERNAL IP WILL BE ADDED
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.environment}-sg"
    "Environment" = "${var.environment}"
  }
}

# ########################################
# ######    SECURITY GROUP RULES
# ########################################
resource "aws_security_group_rule" "access_for_ip" {
  for_each    = toset(var.security_group_allow_ip)
  type        = "ingress"
  from_port   = var.security_group_open_port[0]
  to_port     = var.security_group_open_port[1]
  protocol    = "tcp"
  cidr_blocks = [each.value]

  security_group_id = aws_security_group.sg.id
}

###################

resource "aws_security_group" "private-sg" {

  name = "${var.environment}-demo-private-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    description = "Allow all"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.environment}-private-sg"
    "Environment" = "${var.environment}"
  }
}