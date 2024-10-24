resource "tls_private_key" "ssh_key" {
    algorithm = "RSA"
    rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
    key_name   = "ipt-poc-key"
    public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_instance" "debian12" {
    ami           = "ami-0584590e5f0e97daa" # Replace with the actual Debian 12 AMI ID
    instance_type = "t2.micro"
    
    tags = {
        Name = "ipt_poc_debian12"
    }

    key_name = aws_key_pair.generated_key.key_name

    subnet_id         = aws_subnet.ipt_poc_subnet01.id
    vpc_security_group_ids = [aws_security_group.ipt_poc_vm_sg.id]
    associate_public_ip_address = true
}

resource "local_file" "ssh_private_key" {
    content  = tls_private_key.ssh_key.private_key_pem
    filename = "../ansible/ipt-poc-key"
    file_permission = 600
}

resource "local_file" "ssh_public_key" {
    content  = tls_private_key.ssh_key.public_key_openssh
    filename = "../ansible/ipt-poc-key.pub"
    file_permission = 644
}

resource "local_file" "debian_inventory" {
    content  = <<-EOT
    [ipt_poc_debian12]
    ${aws_instance.debian12.public_ip} ansible_user=admin ansible_ssh_private_key_file=./${aws_key_pair.generated_key.key_name}
    EOT
    filename = "../ansible/inventory"
    file_permission = 644
}

resource "null_resource" "run_ansible_playbook" {
    depends_on = [ aws_instance.debian12, local_file.db_connection_info, local_file.ssh_private_key, local_file.ssh_public_key, local_file.debian_inventory, aws_security_group.ipt_poc_vm_sg, aws_vpc_security_group_ingress_rule.allow_ssh_ipv4, aws_vpc_security_group_ingress_rule.allow_http_ipv4, aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4 ]
    triggers = {
        always_run = timestamp()
    }

  provisioner "local-exec" {
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory ipt-poc.yml"
    working_dir = "../ansible"
  }
}