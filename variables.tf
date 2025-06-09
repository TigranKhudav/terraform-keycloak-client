variable "client_id" {
  description = "Keycloak client secret for Kafka"
  type        = string
}
variable "realm_id" {
  description = "Keycloak client secret for Kafka"
  type        = string
}
variable "roles" {
  description = "Keycloak client secret for Kafka"
  type        = list(string)
  default     = []
}
variable "client_secret" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "access_token_lifespan" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "admin_url" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "always_display_in_console" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = false
}
variable "backchannel_logout_revoke_offline_sessions" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = false
}
variable "backchannel_logout_session_required" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = true
}
variable "backchannel_logout_url" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "base_url" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "client_offline_session_idle_timeout" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "client_offline_session_max_lifespan" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "client_session_idle_timeout" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "client_session_max_lifespan" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "consent_required" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = false
}
variable "consent_screen_text" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "description" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "direct_access_grants_enabled" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = true
}
variable "display_on_consent_screen" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = false
}
variable "client_enabled" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = true
}
variable "frontchannel_logout_enabled" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = true
}
variable "exclude_issuer_from_auth_response" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "frontchannel_logout_url" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "full_scope_allowed" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = true
}
variable "implicit_flow_enabled" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = true
}
variable "import" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = false
}
variable "login_theme" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "name" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "oauth2_device_code_lifespan" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "oauth2_device_polling_interval" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "pkce_code_challenge_method" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "exclude_session_state_from_auth_response" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "oauth2_device_authorization_grant_enabled" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = false
}
variable "use_refresh_tokens" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = false
}
variable "use_refresh_tokens_client_credentials" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = false
}
variable "valid_post_logout_redirect_uris" {
  description = "Keycloak client secret for Kafka"
  type        = list(string)
  default     = []
}
variable "valid_redirect_uris" {
  description = "Keycloak client secret for Kafka"
  type        = list(string)
  default     = ["/*"]
}
variable "web_origins" {
  description = "Keycloak client secret for Kafka"
  type        = list(string)
  default     = ["/*"]
}
variable "root_url" {
  description = "Keycloak client secret for Kafka"
  type        = string
  default     = null
}
variable "service_accounts_enabled" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = true
}
variable "standard_flow_enabled" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = true
}
