output "client_id" {
  value       = keycloak_openid_client.this.id
  description = "The ID of the S3 bucket"
}
output "role_id" {
  value       = keycloak_role.this.id
  description = "The ID of the S3 bucket"
}