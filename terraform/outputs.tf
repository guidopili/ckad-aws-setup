output "master-ip" {
  value = aws_instance.master.public_ip
}

output "minion-ips" {
  value = aws_instance.minion.*.public_ip
}
