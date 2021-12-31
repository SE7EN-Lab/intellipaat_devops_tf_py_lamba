# Bastion host definition
resource "aws_instance" "bastion_host" {
  ami           = var.ami_id
  instance_type = var.inst_type
}

# Security Group definition
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SSH Key pair definition for Bastion host
resource "aws_key_pair" "bastion_ssh_key" {
  key_name   = "my_ssh_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDDXloir3et4o1G5BR+ufuyh7v+Lob+TVaU22iXH5nguRL1HwygeZCjVcp/By8JScmUi93VeMP60fn4thwVMlA0OwzAxWT7+hOcGkS+Sr9GjZolojNhmNGi1rPf+t9BGh77PyeJwssMZULelOtX23c+Ait7bPZzo9kdAlwvn9YB1GNPGosTzTdZ6kj5xKrOsWm1z7j4DPtW9f2iNBUAkrqCUefN3wfDYrbHN8i0CgIMLoOLrBYrJiLMQfo/4bJuCPuxFo1oc65JSWVXSSq44DpNBP3QbfcOaIh91g2NtarkwBfFfYWBIg17yxx3dkjO6MMH7WBLVAwAb3yFSUC328+4icj7eHz4+swbdmiV0TxQ+Y3XmIyNjRJuzXlmZlnbqMMBN33GndKCLsQDXejY8hpiTTwog2XSIiZDBV0Li/JZxubljwfr4aQztOE7IR0V2R/byW7OF1gB3k2Vp6sznsL00bvKQR/lWlnU6poTtdVsr2Op7PwNnlmXNk+M0u3ldtc= plane@SE7EN-PC"
}