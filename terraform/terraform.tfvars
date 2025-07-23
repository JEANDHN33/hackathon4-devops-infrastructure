# Configuration Hackathon 4 - Store API
aws_region              = "eu-west-3"
environment             = "hackathon4"
availability_zones      = ["eu-west-3a", "eu-west-3b"]

# Types d'instances ARM64 optimisées
instance_type_jenkins   = "t4g.large"   # Jenkins a besoin de plus de RAM
instance_type_api       = "t4g.medium"  # Ton Store API + PostgreSQL
instance_type_kong      = "t4g.small"   # Kong Gateway
instance_type_bastion   = "t4g.micro"   # Bastion minimal

key_pair_name           = "hackathon4-keypair"

# Sécurité SSH - Remplace par ton IP publique si possible
# Ex: allowed_ssh_cidr = "90.91.92.93/32"
allowed_ssh_cidr        = "0.0.0.0/0"
