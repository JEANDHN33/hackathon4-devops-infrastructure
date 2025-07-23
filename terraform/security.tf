# Paire de clés SSH
resource "aws_key_pair" "hackathon4_keypair" {
  key_name   = var.key_pair_name
  public_key = file("~/.ssh/hackathon4_rsa.pub")

  tags = {
    Name = "${var.environment}-ssh-keypair"
  }
}

# Security Group pour Bastion Host
resource "aws_security_group" "bastion_sg" {
  name_prefix = "${var.environment}-bastion-"
  vpc_id      = aws_vpc.hackathon4_vpc.id
  description = "Security group for Bastion Host - SSH entry point"

  # SSH sur port custom 4222 (comme dans ton schéma)
  ingress {
    description = "SSH custom port pour Bastion"
    from_port   = 4222
    to_port     = 4222
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-bastion-security-group"
    Role = "bastion-host"
  }
}

# Security Group pour Jenkins Server
resource "aws_security_group" "jenkins_sg" {
  name_prefix = "${var.environment}-jenkins-"
  vpc_id      = aws_vpc.hackathon4_vpc.id
  description = "Security group for Jenkins CI/CD Server"

  # SSH depuis Bastion uniquement
  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Jenkins Web UI depuis Bastion (pour port forwarding)
  ingress {
    description     = "Jenkins Web from Bastion"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-jenkins-security-group"
    Role = "cicd-server"
  }
}

# Security Group pour API Server (Store API)
resource "aws_security_group" "api_server_sg" {
  name_prefix = "${var.environment}-api-server-"
  vpc_id      = aws_vpc.hackathon4_vpc.id
  description = "Security group for Store API Server"

  # SSH depuis Bastion
  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # API depuis Jenkins (pour déploiement)
  ingress {
    description     = "Store API from Jenkins"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }

  # API depuis Kong Gateway
  ingress {
    description     = "Store API from Kong Gateway"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.kong_sg.id]
  }

  # PostgreSQL depuis Jenkins (pour déploiement)
  ingress {
    description     = "PostgreSQL from Jenkins"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-api-server-security-group"
    Role = "application-server"
  }
}

# Security Group pour Kong Gateway
resource "aws_security_group" "kong_sg" {
  name_prefix = "${var.environment}-kong-"
  vpc_id      = aws_vpc.hackathon4_vpc.id
  description = "Security group for Kong API Gateway"

  # SSH depuis Bastion
  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Kong Proxy public (port 8000 comme dans ton schéma)
  ingress {
    description = "Kong Proxy public"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kong Admin depuis Bastion (pour configuration)
  ingress {
    description     = "Kong Admin from Bastion"
    from_port       = 8001
    to_port         = 8001
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-kong-security-group"
    Role = "api-gateway"
  }
}
