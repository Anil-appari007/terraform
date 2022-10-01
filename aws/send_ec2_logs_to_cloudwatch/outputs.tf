output "local_workstation_ip" {
  value = local.workstation_external_ip
}
output "ec2_public_ip" {
  value = aws_instance.ec2[*].public_ip
}