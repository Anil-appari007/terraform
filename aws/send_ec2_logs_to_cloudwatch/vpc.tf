########################################
######    VPC
########################################
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.environment}-vpc"
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
  }
}


########################################
######    SUBNET
########################################
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr

  tags = {
    Name = "${var.environment}-subnet"
  }
}

########################################
######    PUBLIC ROUTE TABLE
########################################
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    "Name" = "${var.environment}-public-route-table"
  }
}

########################################
######    ATTACH ROUTE TABLE TO SUBNET
########################################
resource "aws_route_table_association" "rta-sub" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.public-rt.id
}

########################################
######    SECURITY GROUP
########################################
resource "aws_security_group" "sg" {

  name = "${var.environment}-demo-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = var.security_group_open_port[0]
    to_port   = var.security_group_open_port[1]
    protocol  = "tcp"

    cidr_blocks = [local.workstation_external_ip]   ## YOUR EXTERNAL IP WILL BE ADDED

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################################
######    SECURITY GROUP RULES
########################################
resource "aws_security_group_rule" "access_for_ip" {
  for_each    = toset(var.security_group_allow_ip)
  type        = "ingress"
  from_port   = var.security_group_open_port[0]
  to_port     = var.security_group_open_port[1]
  protocol    = "tcp"
  cidr_blocks = [each.value]

  security_group_id = aws_security_group.sg.id
}