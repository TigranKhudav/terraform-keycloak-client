# -------------------------
# Keycloak Client
# -------------------------
resource "keycloak_openid_client" "this" {
  access_token_lifespan                          = var.access_token_lifespan
  access_type                                    = var.access_type
  admin_url                                      = var.admin_url
  always_display_in_console                      = var.always_display_in_console
  backchannel_logout_revoke_offline_sessions     = var.backchannel_logout_revoke_offline_sessions
  backchannel_logout_session_required            = var.backchannel_logout_session_required
  backchannel_logout_url                         = var.backchannel_logout_url
  base_url                                       = var.base_url
  client_authenticator_type                      = var.client_authenticator_type
  client_id                                      = var.client_id
  client_offline_session_idle_timeout            = var.client_offline_session_idle_timeout
  client_offline_session_max_lifespan            = var.client_offline_session_max_lifespan
  client_secret                                  = var.client_secret
  client_session_idle_timeout                    = var.client_session_idle_timeout
  client_session_max_lifespan                    = var.client_session_max_lifespan
  consent_required                               = var.consent_required
  consent_screen_text                            = var.consent_screen_text
  description                                    = var.description
  direct_access_grants_enabled                   = var.direct_access_grants_enabled
  display_on_consent_screen                      = var.display_on_consent_screen
  enabled                                        = var.client_enabled
  exclude_issuer_from_auth_response              = var.exclude_issuer_from_auth_response
  exclude_session_state_from_auth_response       = var.exclude_session_state_from_auth_response
  extra_config                                   = var.extra_config
  frontchannel_logout_enabled                    = var.frontchannel_logout_enabled
  frontchannel_logout_url                        = var.frontchannel_logout_url
  full_scope_allowed                             = var.full_scope_allowed
  implicit_flow_enabled                          = var.implicit_flow_enabled
  import                                         = var.import
  login_theme                                    = var.login_theme
  name                                           = var.name
  oauth2_device_authorization_grant_enabled      = var.oauth2_device_authorization_grant_enabled
  oauth2_device_code_lifespan                    = var.oauth2_device_code_lifespan
  oauth2_device_polling_interval                 = var.oauth2_device_polling_interval
  pkce_code_challenge_method                     = var.pkce_code_challenge_method
  realm_id                                       = var.realm_id
  root_url                                       = var.root_url
  service_accounts_enabled                       = var.service_accounts_enabled
  standard_flow_enabled                          = var.standard_flow_enabled
  use_refresh_tokens                             = var.use_refresh_tokens
  use_refresh_tokens_client_credentials          = var.use_refresh_tokens_client_credentials
  require_dpop_bound_tokens                      = var.require_dpop_bound_tokens
  standard_token_exchange_enabled                = var.standard_token_exchange_enabled
  allow_refresh_token_in_standard_token_exchange = var.allow_refresh_token_in_standard_token_exchange
  valid_post_logout_redirect_uris                = var.valid_post_logout_redirect_uris
  valid_redirect_uris                            = var.valid_redirect_uris
  web_origins                                    = var.web_origins
  dynamic "authentication_flow_binding_overrides" {
    for_each = var.authentication_flow_binding_overrides != null ? [var.authentication_flow_binding_overrides] : []
    content {
      browser_id      = authentication_flow_binding_overrides.value.browser_id
      direct_grant_id = authentication_flow_binding_overrides.value.direct_grant_id
    }
  }
  dynamic "authorization" {
    for_each = var.authorization != null ? [var.authorization] : []
    content {
      policy_enforcement_mode          = authorization.value.policy_enforcement_mode
      decision_strategy                = authorization.value.decision_strategy
      allow_remote_resource_management = authorization.value.allow_remote_resource_management
      keep_defaults                    = authorization.value.keep_defaults
    }
  }

  lifecycle {
    # Authorization services are often enabled out-of-band in Keycloak. Don't
    # remove or churn the block when a caller doesn't declare it; manage it on
    # create only. Remove this if you want Terraform to fully own authorization.
    ignore_changes = [authorization]
  }
}
# Attach roles to the service account
# Keyed by role name (not list index) so instance addresses are stable and
# match existing state — avoids destroy/recreate churn when the list changes.
resource "keycloak_openid_client_service_account_realm_role" "this" {
  for_each                = toset(var.service_accounts_roles)
  realm_id                = var.realm_id
  service_account_user_id = keycloak_openid_client.this.service_account_user_id
  role                    = each.value
  depends_on              = [keycloak_openid_client.this]
}
# Attach roles to the roles
resource "keycloak_role" "this" {
  for_each  = length(var.roles) > 0 ? toset(var.roles) : []
  realm_id  = var.realm_id
  client_id = keycloak_openid_client.this.id
  name      = each.value
}
# Attach this client's own client roles to its own service account
resource "keycloak_openid_client_service_account_role" "this" {
  for_each                = toset(var.service_accounts_client_roles)
  realm_id                = var.realm_id
  service_account_user_id = keycloak_openid_client.this.service_account_user_id
  client_id               = keycloak_openid_client.this.id
  role                    = keycloak_role.this[each.value].name
}
# Attach roles owned by OTHER clients (by role ID) to this client's service account
resource "keycloak_user_roles" "external" {
  count      = length(var.service_accounts_role_ids) > 0 ? 1 : 0
  realm_id   = var.realm_id
  user_id    = keycloak_openid_client.this.service_account_user_id
  role_ids   = var.service_accounts_role_ids
  exhaustive = false
}
# -------------------------
# Audience Protocol Mappers
# -------------------------
resource "keycloak_openid_audience_protocol_mapper" "this" {
  for_each  = var.audience_mappers
  realm_id  = var.realm_id
  client_id = keycloak_openid_client.this.id
  name      = each.key

  included_custom_audience = try(each.value.included_custom_audience, null)
  included_client_audience = try(each.value.included_client_audience, null)
  add_to_access_token      = each.value.add_to_access_token
  add_to_id_token          = each.value.add_to_id_token
  depends_on               = [keycloak_openid_client.this]
}
# -------------------------
# Session Note Protocol Mappers
# -------------------------
resource "keycloak_openid_user_session_note_protocol_mapper" "this" {
  for_each  = var.user_session_note_mappers
  realm_id  = var.realm_id
  client_id = keycloak_openid_client.this.id
  name      = each.key

  claim_name                 = each.value.claim_name
  session_note               = each.value.session_note
  claim_value_type           = each.value.claim_value_type
  add_to_access_token        = each.value.add_to_access_token
  add_to_id_token            = each.value.add_to_id_token
  add_to_token_introspection = each.value.add_to_token_introspection
  depends_on                 = [keycloak_openid_client.this]
}
# -------------------------
# User Attribute Protocol Mappers
# -------------------------
resource "keycloak_openid_user_attribute_protocol_mapper" "this" {
  for_each                   = var.user_attribute_mappers
  realm_id                   = var.realm_id
  client_id                  = keycloak_openid_client.this.id
  name                       = each.key
  claim_name                 = each.value.claim_name
  user_attribute             = each.value.user_attribute
  claim_value_type           = each.value.claim_value_type
  add_to_access_token        = each.value.add_to_access_token
  add_to_id_token            = each.value.add_to_id_token
  add_to_token_introspection = each.value.add_to_token_introspection
  aggregate_attributes       = each.value.aggregate_attributes
  add_to_userinfo            = each.value.add_to_userinfo
  multivalued                = each.value.multivalued
  depends_on                 = [keycloak_openid_client.this]
}
# -------------------------
# Group Attribute Protocol Mappers
# -------------------------
resource "keycloak_openid_group_membership_protocol_mapper" "this" {
  for_each            = var.group_attribute_mappers
  realm_id            = var.realm_id
  client_id           = keycloak_openid_client.this.id
  name                = each.key
  claim_name          = each.value.claim_name
  full_path           = each.value.full_path
  add_to_id_token     = each.value.add_to_id_token
  add_to_access_token = each.value.add_to_access_token
  add_to_userinfo     = each.value.add_to_userinfo
  depends_on          = [keycloak_openid_client.this]
}
# -------------------------
# User Realm Role Protocol Mappers
# -------------------------
resource "keycloak_openid_user_realm_role_protocol_mapper" "this" {
  for_each                   = var.user_realm_role_mappers
  realm_id                   = var.realm_id
  client_id                  = keycloak_openid_client.this.id
  name                       = each.key
  claim_name                 = each.value.claim_name
  claim_value_type           = each.value.claim_value_type
  realm_role_prefix          = each.value.realm_role_prefix
  multivalued                = each.value.multivalued
  add_to_id_token            = each.value.add_to_id_token
  add_to_access_token        = each.value.add_to_access_token
  add_to_userinfo            = each.value.add_to_userinfo
  add_to_token_introspection = each.value.add_to_token_introspection
  depends_on                 = [keycloak_openid_client.this]
}

# -------------------------
# User Client Role Protocol Mappers
# -------------------------
resource "keycloak_openid_user_client_role_protocol_mapper" "this" {
  for_each                    = var.user_client_role_mappers
  realm_id                    = var.realm_id
  client_id                   = keycloak_openid_client.this.id
  name                        = each.key
  claim_name                  = each.value.claim_name
  client_id_for_role_mappings = each.value.client_id_for_role_mappings
  client_role_prefix          = each.value.client_role_prefix
  claim_value_type            = each.value.claim_value_type
  multivalued                 = each.value.multivalued
  add_to_id_token             = each.value.add_to_id_token
  add_to_access_token         = each.value.add_to_access_token
  add_to_userinfo             = each.value.add_to_userinfo
  depends_on                  = [keycloak_openid_client.this]
}

# -------------------------
# Hardcoded Claim Protocol Mappers
# -------------------------
resource "keycloak_openid_hardcoded_claim_protocol_mapper" "this" {
  for_each            = var.hardcoded_claim_mappers
  realm_id            = var.realm_id
  client_id           = keycloak_openid_client.this.id
  name                = each.key
  claim_name          = each.value.claim_name
  claim_value         = each.value.claim_value
  claim_value_type    = each.value.claim_value_type
  add_to_id_token     = each.value.add_to_id_token
  add_to_access_token = each.value.add_to_access_token
  add_to_userinfo     = each.value.add_to_userinfo
  depends_on          = [keycloak_openid_client.this]
}

# -------------------------
# Generic Protocol Mappers
# -------------------------
resource "keycloak_generic_protocol_mapper" "this" {
  for_each        = var.generic_protocol_mappers
  realm_id        = var.realm_id
  client_id       = keycloak_openid_client.this.id
  name            = each.key
  protocol        = each.value.protocol
  protocol_mapper = each.value.protocol_mapper
  config          = each.value.config
  depends_on      = [keycloak_openid_client.this]
}

# -------------------------
# Client Scopes (default / optional)
# -------------------------
resource "keycloak_openid_client_default_scopes" "this" {
  count          = var.default_client_scopes != null ? 1 : 0
  realm_id       = var.realm_id
  client_id      = keycloak_openid_client.this.id
  default_scopes = var.default_client_scopes
}

resource "keycloak_openid_client_optional_scopes" "this" {
  count           = var.optional_client_scopes != null ? 1 : 0
  realm_id        = var.realm_id
  client_id       = keycloak_openid_client.this.id
  optional_scopes = var.optional_client_scopes
}
