# Instance Bastion Host
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux_arm64.id
  instance_type          = var.instance_type_bastion
  subnet_id              = aws_subnet.public_subnets[1].id  # AZ différente
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.hackathon4_keypair.key_name

  user_data = base64encode(file("${path.module}/userdata/bastion.sh"))

  root_block_device {
    volume_type           = "gp3"
    volume_size = 30
    delete_on_termination = true
    encrypted            = true
  }

  tags = {
    Name = "${var.environment}-bastion-host"
    Type = "bastion"
    Role = "security-gateway"
  }
}

# Instance Jenkins Server
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon_linux_arm64.id
  instance_type          = var.instance_type_jenkins
  subnet_id              = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = aws_key_pair.hackathon4_keypair.key_name

  user_data = base64encode(file("${path.module}/userdata/jenkins.sh"))

  root_block_device {
    volume_type           = "gp3"
    volume_size = 30
    delete_on_termination = true
    encrypted            = true
  }

  tags = {
    Name = "${var.environment}-jenkins-server"
    Type = "jenkins"
    Role = "cicd-pipeline"
  }
}

# Instance API Server (Store API)
resource "aws_instance" "api_server" {
  ami                    = data.aws_ami.amazon_linux_arm64.id
  instance_type          = var.instance_type_api
  subnet_id              = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.api_server_sg.id]
  key_name               = aws_key_pair.hackathon4_keypair.key_name

  user_data = base64encode(file("${path.module}/userdata/api-server.sh"))

  root_block_device {
    volume_type           = "gp3"
    volume_size = 30
    delete_on_termination = true
    encrypted            = true
  }

  tags = {
    Name = "${var.environment}-store-api-server"
    Type = "api-server"
    Role = "application"
  }
}

# Instance Kong Gateway
resource "aws_instance" "kong" {
  ami                    = data.aws_ami.amazon_linux_arm64.id
  instance_type          = var.instance_type_kong
  subnet_id              = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.kong_sg.id]
  key_name               = aws_key_pair.hackathon4_keypair.key_name

  user_data = base64encode(file("${path.module}/userdata/kong.sh"))

  root_block_device {
    volume_type           = "gp3"
    volume_size = 30
    delete_on_termination = true
    encrypted            = true
  }

  tags = {
    Name = "${var.environment}-kong-gateway"
    Type = "kong-gateway"
    Role = "api-gateway"
  }
}
