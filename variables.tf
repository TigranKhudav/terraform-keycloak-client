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