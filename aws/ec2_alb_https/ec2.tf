#######################################
#####    CREATE SSH KEYS
#######################################
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./tls/private.pem"
  file_permission = "0600"
}

########################################
######    CREATE KEY PAIR
########################################
resource "aws_key_pair" "tf-ssh-key" {
  key_name   = "${var.environment}-ssh-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

########################################
######    CREATE EC2
########################################
resource "aws_instance" "public-ec2" {
  count = var.public_instance_count
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.tf-ssh-key.key_name
  vpc_security_group_ids = [
    aws_security_group.allow_80.id,
    aws_security_group.allow_ssh_to_workstation.id,
    aws_security_group.allow_443.id
    ]
  tags = {
    Name = "${var.environment}-vm-${count.index}"
  }
  subnet_id                   = aws_subnet.public-subnet[count.index].id
  user_data = <<-EOF
  #!/bin/bash
  apt update -y
  apt install -y nginx
  echo "Hello from $(hostname)" > /var/www/html/*.html
  EOF

}