output "client_id" {
  value       = keycloak_openid_client.this.id
  description = "The ID of the S3 bucket"
}
output "role_id" {
  value = {
    for k, role in keycloak_role.this : k => role.id
  }
}
