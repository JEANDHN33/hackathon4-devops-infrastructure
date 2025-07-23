variable "aws_region" {
  description = "Région AWS pour le déploiement"
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "Nom de l'environnement"
  type        = string
  default     = "hackathon4"
}

variable "availability_zones" {
  description = "Zones de disponibilité"
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b"]
}

variable "instance_type_jenkins" {
  description = "Type d'instance pour Jenkins"
  type        = string
  default     = "t4g.large"  # ARM64 avec plus de RAM pour Jenkins
}

variable "instance_type_api" {
  description = "Type d'instance pour l'API Server"
  type        = string
  default     = "t4g.medium"  # ARM64 pour ton application Store
}

variable "instance_type_kong" {
  description = "Type d'instance pour Kong Gateway"
  type        = string
  default     = "t4g.small"   # ARM64 pour Kong
}

variable "instance_type_bastion" {
  description = "Type d'instance pour le Bastion"
  type        = string
  default     = "t4g.micro"   # ARM64 minimal pour le bastion
}

variable "key_pair_name" {
  description = "Nom de la paire de clés SSH"
  type        = string
  default     = "hackathon4-keypair"
}

variable "allowed_ssh_cidr" {
  description = "CIDR autorisé pour SSH (ton IP publique recommandée)"
  type        = string
  default     = "0.0.0.0/0"  # À restreindre en production
}
