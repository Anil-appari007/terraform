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