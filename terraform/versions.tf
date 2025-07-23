terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "hackathon4"
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = "JEANDHN33"
      Architecture = "ARM64"
    }
  }
}
