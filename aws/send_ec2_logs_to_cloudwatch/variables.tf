variable "region" {
    default = "us-east-1"
}
variable "environment" {
    default = "dev"
}
variable "vpc_cidr" {
    default = "18.0.0.0/16"
}

variable "subnet_cidr" {
    default = "18.0.0.0/24"
}

variable "security_group_open_port" {
    default = [22, 22]
}
variable "security_group_allow_ip" {
    default = ["180.0.0.0/32"]
}

variable "instance_count" {
    default = 1
}

variable "instance_type" {
    default = "t2.micro"
}
variable "instance_ami" {
    default = "ami-026b57f3c383c2eec" ## amazon linux
}