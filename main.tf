resource "keycloak_openid_client" "this" {
  access_token_lifespan                      = null
  access_type                                = "CONFIDENTIAL"
  admin_url                                  = null
  always_display_in_console                  = false
  backchannel_logout_revoke_offline_sessions = false
  backchannel_logout_session_required        = true
  backchannel_logout_url                     = null
  base_url                                   = null
  client_authenticator_type                  = "client-secret"
  client_id                                  = var.client_id
  client_offline_session_idle_timeout        = null
  client_offline_session_max_lifespan        = null
  client_secret                              = null
  client_session_idle_timeout                = null
  client_session_max_lifespan                = null
  consent_required                           = false
  consent_screen_text                        = null
  description                                = null
  direct_access_grants_enabled               = false
  display_on_consent_screen                  = false
  enabled                                    = true
  exclude_issuer_from_auth_response          = null
  exclude_session_state_from_auth_response   = null
  extra_config                               = {}
  frontchannel_logout_enabled                = true
  frontchannel_logout_url                    = null
  full_scope_allowed                         = true
  implicit_flow_enabled                      = true
  import                                     = false
  login_theme                                = null
  name                                       = null
  oauth2_device_authorization_grant_enabled  = false
  oauth2_device_code_lifespan                = null
  oauth2_device_polling_interval             = null
  pkce_code_challenge_method                 = null
  realm_id                                   = var.realm_id
  root_url                                   = null
  service_accounts_enabled                   = true
  standard_flow_enabled                      = true
  use_refresh_tokens                         = false
  use_refresh_tokens_client_credentials      = false
  valid_post_logout_redirect_uris            = []
  valid_redirect_uris                        = ["/*"]
  web_origins                                = ["/*"]
}

# Attach roles to the service account
resource "keycloak_openid_client_service_account_realm_role" "this" {
  for_each                = length(var.roles) > 0 ? toset(var.roles) : []
  realm_id                = var.realm_id
  service_account_user_id = keycloak_openid_client.this.service_account_user_id
  role                    = each.value
  depends_on = [ keycloak_openid_client.this ]
}
