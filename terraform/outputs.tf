# IPs publiques
output "bastion_public_ip" {
  description = "IP publique du Bastion Host"
  value       = aws_instance.bastion.public_ip
}

output "kong_public_ip" {
  description = "IP publique de Kong Gateway"
  value       = aws_instance.kong.public_ip
}

# IPs privées
output "jenkins_private_ip" {
  description = "IP privée de Jenkins Server"
  value       = aws_instance.jenkins.private_ip
}

output "api_server_private_ip" {
  description = "IP privée de l'API Server"
  value       = aws_instance.api_server.private_ip
}

output "kong_private_ip" {
  description = "IP privée de Kong Gateway"
  value       = aws_instance.kong.private_ip
}

# Instance IDs
output "instance_ids" {
  description = "IDs des instances EC2"
  value = {
    bastion    = aws_instance.bastion.id
    jenkins    = aws_instance.jenkins.id
    api_server = aws_instance.api_server.id
    kong       = aws_instance.kong.id
  }
}

# Résumé de l'architecture
output "architecture_summary" {
  description = "Résumé de l'architecture déployée"
  value = {
    bastion = {
      public_ip = aws_instance.bastion.public_ip
      ssh_port = 4222
      role = "🛡️ Security Gateway"
    }
    jenkins = {
      private_ip = aws_instance.jenkins.private_ip
      web_port = 8080
      role = "🚀 CI/CD Pipeline"
    }
    api_server = {
      private_ip = aws_instance.api_server.private_ip
      api_port = 8080
      role = "📱 Store API Server"
    }
    kong = {
      public_ip = aws_instance.kong.public_ip
      proxy_port = 8000
      admin_port = 8001
      role = "🌐 API Gateway"
    }
  }
}

# URLs d'accès
output "access_urls" {
  description = "URLs et commandes d'accès"
  value = {
    bastion_ssh = "ssh -p 4222 ec2-user@${aws_instance.bastion.public_ip}"
    kong_public_api = "http://${aws_instance.kong.public_ip}:8000"
    jenkins_tunnel = "ssh -L 8080:localhost:8080 jenkins"
    kong_admin_tunnel = "ssh -L 8001:localhost:8001 kong-server"
  }
}
