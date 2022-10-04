variable "region" {
    default = "us-east-1"
}
variable "environment" {
    default = "dev"
}   
variable "vpc_cidr" {
    default = "18.0.0.0/16"
}

variable "public_subnet_cidr" {
    default = ["18.0.0.0/24","18.0.1.0/24"]   ##,"18.0.2.0/24"
}

variable "private_subnet_cidr" {
    default = ["18.0.10.0/24","18.0.11.0/24",]   ##,"18.0.11.0/24"
}

variable "public_instance_count" {
    default = 2
}
variable "private_instance_count" {
    default = 2
}
variable "instance_type" {
    default = "t2.micro"
}
variable "instance_ami" {
    # default = "ami-026b57f3c383c2eec" ## amazon linux
    default = "ami-0c1704bac156af62c"   ## Ubuntu
    
}

############
##  To allow ssh to another IP as your requirement
##  change false -> true

variable "allow_ssh_to_another_ip" {
    default = {
        "allow" = false,
        "cidr_to_allow" = ["17.0.0.0/32","19.0.0.0/32"]
    }
}

###########################################
#######   DNS Values
###########################################
variable "dns_name" {
    default = "ur.domain.name"     #### Give a DNS Name which u have configured in Route53
}

variable "dns_zone_id" {
    default = "98uyt*********"    #### Zone ID
}