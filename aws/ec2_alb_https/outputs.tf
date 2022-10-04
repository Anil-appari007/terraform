output "local_workstation_ip" {
  value = local.workstation_external_ip
}
output "ec2_public_ip" {
  value = aws_instance.public-ec2[*].public_ip
}
output "alb_dns" {
    value = aws_lb.frontend_lb.dns_name
}