########################################
######    CREATE SSH KEYS
########################################
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
resource "aws_instance" "ec2" {
  count = var.instance_count
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.tf-ssh-key.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = "${var.environment}-vm"
  }
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet.id
  iam_instance_profile = aws_iam_instance_profile.profile.id

  user_data = <<-EOF
  #!/bin/bash
  yum update -y
  yum install -y awslogs
  systemctl start awslogsd
  EOF
}