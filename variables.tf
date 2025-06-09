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
variable "direct_access_grants_enabled" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = false
}

variable "frontchannel_logout_enabled" {
  description = "Keycloak client secret for Kafka"
  type        = bool
  default     = true
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