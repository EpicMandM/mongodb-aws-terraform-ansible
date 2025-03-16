output "ec2_public_ip" {
  value = aws_instance.nebo-task-vm.public_ip
  
}