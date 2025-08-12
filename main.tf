# -------------------------
# Keycloak Client
# -------------------------
resource "keycloak_openid_client" "this" {
  access_token_lifespan                      = var.access_token_lifespan
  access_type                                = var.access_type
  admin_url                                  = var.admin_url
  always_display_in_console                  = var.always_display_in_console
  backchannel_logout_revoke_offline_sessions = var.backchannel_logout_revoke_offline_sessions
  backchannel_logout_session_required        = var.backchannel_logout_session_required
  backchannel_logout_url                     = var.backchannel_logout_url
  base_url                                   = var.base_url
  client_authenticator_type                  = "client-secret"
  client_id                                  = var.client_id
  client_offline_session_idle_timeout        = var.client_offline_session_idle_timeout
  client_offline_session_max_lifespan        = var.client_offline_session_max_lifespan
  client_secret                              = var.client_secret
  client_session_idle_timeout                = var.client_session_idle_timeout
  client_session_max_lifespan                = var.client_session_max_lifespan
  consent_required                           = var.consent_required
  consent_screen_text                        = var.consent_screen_text
  description                                = var.description
  direct_access_grants_enabled               = var.direct_access_grants_enabled
  display_on_consent_screen                  = var.display_on_consent_screen
  enabled                                    = var.client_enabled
  exclude_issuer_from_auth_response          = var.exclude_issuer_from_auth_response
  exclude_session_state_from_auth_response   = var.exclude_session_state_from_auth_response
  extra_config                               = {}
  frontchannel_logout_enabled                = var.frontchannel_logout_enabled
  frontchannel_logout_url                    = var.frontchannel_logout_url
  full_scope_allowed                         = var.full_scope_allowed
  implicit_flow_enabled                      = var.implicit_flow_enabled
  import                                     = var.import
  login_theme                                = var.login_theme
  name                                       = var.name
  oauth2_device_authorization_grant_enabled  = var.oauth2_device_authorization_grant_enabled
  oauth2_device_code_lifespan                = var.oauth2_device_code_lifespan
  oauth2_device_polling_interval             = var.oauth2_device_polling_interval
  pkce_code_challenge_method                 = var.pkce_code_challenge_method
  realm_id                                   = var.realm_id
  root_url                                   = var.root_url
  service_accounts_enabled                   = var.service_accounts_enabled
  standard_flow_enabled                      = var.standard_flow_enabled
  use_refresh_tokens                         = var.use_refresh_tokens
  use_refresh_tokens_client_credentials      = var.use_refresh_tokens_client_credentials
  valid_post_logout_redirect_uris            = var.valid_post_logout_redirect_uris
  valid_redirect_uris                        = var.valid_redirect_uris
  web_origins                                = var.web_origins
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
      policy_enforcement_mode = authorization.value.policy_enforcement_mode
      decision_strategy       = authorization.value.decision_strategy
    }
  }
}
# Attach roles to the service account
resource "keycloak_openid_client_service_account_realm_role" "this" {
  for_each                = length(var.service_accounts_roles) > 0 ? toset(var.service_accounts_roles) : []
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


# -------------------------
# Audience Protocol Mappers
# -------------------------
resource "keycloak_openid_audience_protocol_mapper" "audience" {
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
resource "keycloak_openid_user_session_note_protocol_mapper" "user_session_note" {
  for_each  = var.user_session_note_mappers
  realm_id  = var.realm_id
  client_id = keycloak_openid_client.this.id
  name      = each.key

  claim_name          = each.value.claim_name
  session_note        = each.value.session_note
  claim_value_type    = each.value.claim_value_type
  add_to_access_token = each.value.add_to_access_token
  add_to_id_token     = each.value.add_to_id_token
  depends_on          = [keycloak_openid_client.this]
}
