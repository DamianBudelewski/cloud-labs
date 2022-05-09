output "ssh_application_instance" {
  value = join("@", ["ssh ubuntu", replace(trimsuffix(trimprefix(module.application_instance.private_dns,"ip-"),".ec2.internal"),"-",".")])
}

output "ssh_bastion_instance" {
  value = "ssh-add -K mastering-aws.pem; ssh -A ubuntu@${module.bastion_instance.public_ip}"
}
