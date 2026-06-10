output "client_id" {
  value       = keycloak_openid_client.this.id
  description = "Internal Keycloak ID (UUID) of the created client."
}

output "client_uuid" {
  value       = keycloak_openid_client.this.id
  description = "Alias of client_id: the internal Keycloak UUID of the client."
}

output "client_client_id" {
  value       = keycloak_openid_client.this.client_id
  description = "The client_id (clientId) string of the created client."
}

output "service_account_user_id" {
  value       = try(keycloak_openid_client.this.service_account_user_id, null)
  description = "User ID of the client's service account (null when service accounts are disabled)."
}

output "resource_server_id" {
  value       = try(keycloak_openid_client.this.resource_server_id, null)
  description = "Resource server ID when fine-grained authorization is enabled."
}

output "role_id" {
  value       = try({ for k, role in keycloak_role.this : k => role.id }, {})
  description = "Map of client role name => role ID for the roles created by this module."
}
