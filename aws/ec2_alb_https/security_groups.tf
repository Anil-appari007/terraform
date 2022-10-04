# ########################################
# ######    SECURITY GROUP
# ########################################

resource "aws_security_group" "allow_80" {
    name = "${var.environment}-allow_80"
    vpc_id = aws_vpc.vpc.id
    ingress {
        from_port = 80  
        to_port   = 80 
        protocol  = "tcp"
        description = "Allow 80 to all"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        "Name" = "${var.environment}-sg-allow_80"
        "Environment" = "${var.environment}"
    }
}

resource "aws_security_group" "allow_443" {
    name = "${var.environment}-allow_443"
    vpc_id = aws_vpc.vpc.id
    ingress {
        from_port = 443  
        to_port   = 443
        protocol  = "tcp"
        description = "Allow 443 to all"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        "Name" = "${var.environment}-sg-allow_443"
        "Environment" = "${var.environment}"
    }
}

resource "aws_security_group" "allow_ssh_to_workstation" {
    name = "${var.environment}-sg-allow_ssh_to_workstation"
    vpc_id = aws_vpc.vpc.id
    ingress {
        from_port = 22
        to_port   = 22
        protocol  = "tcp"
        description = "Allow workstation IP"
        cidr_blocks = [local.workstation_external_ip]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        "Name" = "${var.environment}-sg-allow_ssh_to_workstation"
        "Environment" = "${var.environment}"
    }
}


resource "aws_security_group" "allow_ssh_to_another_ip" {
    count = var.allow_ssh_to_another_ip.allow ? 1 : 0
    name = "${var.environment}-sg-allow_ssh_to_given_ip"
    vpc_id = aws_vpc.vpc.id
    ingress {
        from_port = 22  
        to_port   = 22 
        protocol  = "tcp"
        description = "Allow ssh to another IP"
        cidr_blocks = var.allow_ssh_to_another_ip.cidr_to_allow
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        "Name" = "${var.environment}-sg-allow_ssh_to_given_IP"
        "Environment" = "${var.environment}"
    }
}