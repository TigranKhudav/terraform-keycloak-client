# Terraform Keycloak Client module

Creates a Keycloak OpenID client together with its client roles, service-account
role assignments, client scopes, and protocol mappers — in a single module call.

## Requirements

| Name     | Version    |
|----------|------------|
| Terraform | >= 1.3 (uses `optional()` object attributes) |
| `keycloak/keycloak` provider | >= 5.10.0 |

## Usage

### Minimal client

```hcl
module "my_service" {
  source  = "TigranKhudav/client/keycloak"
  version = "0.5.0"

  client_id = "my-service"
  realm_id  = keycloak_realm.internal.id
}
```

### Confidential service-to-service client

```hcl
module "my_service" {
  source  = "TigranKhudav/client/keycloak"
  version = "0.5.0"

  client_id                    = "my-service"
  client_secret                = var.my_service_client_secret
  realm_id                     = keycloak_realm.internal.id
  standard_flow_enabled        = false
  direct_access_grants_enabled = false
  service_accounts_enabled     = true
}
```

### Browser / frontend client

```hcl
module "portal" {
  source  = "TigranKhudav/client/keycloak"
  version = "0.5.0"

  client_id             = "portal"
  realm_id              = keycloak_realm.internal.id
  access_type           = "PUBLIC"
  standard_flow_enabled = true
  valid_redirect_uris   = ["https://portal.example.com/*"]
  web_origins           = ["https://portal.example.com"]
}
```

## Roles

`roles` creates **client roles** on this client. `service_accounts_roles` assigns
existing **realm roles** (by name) to this client's service account — typically the
producer/consumer roles emitted by the companion `TigranKhudav/kafka/keycloak` module.

```hcl
module "consumer" {
  source  = "TigranKhudav/client/keycloak"
  version = "0.5.0"

  client_id = "consumer"
  realm_id  = keycloak_realm.internal.id

  roles                  = ["reader", "writer"]
  service_accounts_roles = [
    module.some_topic.consumer,   # realm role names from the kafka module
    module.some_topic.producer,
  ]
}
```

### Assign a client's own roles to its own service account

Use `service_accounts_client_roles` to grant this client's **own** client roles
(declared in `roles`) to its **own** service account. This is done **inside** the
module — do **not** reference the module from its own arguments (that produces a
dependency cycle).

```hcl
module "crm_tariff" {
  source  = "TigranKhudav/client/keycloak"
  version = "0.5.0"

  client_id = "ceci.crm.tariff"
  realm_id  = keycloak_realm.internal.id

  roles                         = ["sp-application-edit", "sp-application-read"]
  service_accounts_client_roles = ["sp-application-edit", "sp-application-read"]
}
```

> `service_accounts_client_roles` must be a subset of `roles`.

### Assign another client's roles to this service account

Use `service_accounts_role_ids` to grant roles owned by **other** clients to this
client's service account. Pass role **IDs**: another module instance exposes them via
its `role_id` output, and built-in client roles (e.g. `realm-management`) can be
looked up with the `keycloak_role` data source.

```hcl
data "keycloak_openid_client" "realm_management" {
  realm_id  = keycloak_realm.internal.id
  client_id = "realm-management"
}

data "keycloak_role" "view_users" {
  realm_id  = keycloak_realm.internal.id
  client_id = data.keycloak_openid_client.realm_management.id
  name      = "view-users"
}

module "worker" {
  source  = "TigranKhudav/client/keycloak"
  version = "0.5.0"

  client_id = "worker"
  realm_id  = keycloak_realm.internal.id

  service_accounts_role_ids = [
    module.api.role_id["reader"],      # client role created by another module instance
    data.keycloak_role.view_users.id,  # built-in client role
  ]
}
```

## Client scopes

Setting either variable manages that scope assignment; leaving it `null` (default)
leaves Keycloak's scopes untouched.

```hcl
default_client_scopes  = ["profile", "email", "roles", "web-origins"]
optional_client_scopes = ["offline_access", "microprofile-jwt"]
```

## Fine-grained authorization

```hcl
authorization = {
  policy_enforcement_mode          = "ENFORCING"
  decision_strategy                = "AFFIRMATIVE"
  allow_remote_resource_management = true
}
```

## Token exchange / DPoP (provider 5.6+)

```hcl
require_dpop_bound_tokens                      = true
standard_token_exchange_enabled                = true
allow_refresh_token_in_standard_token_exchange = "SAME_SESSION"
```

## Protocol mappers

All mapper variables are maps keyed by the mapper's display name.

```hcl
# Audience
audience_mappers = {
  "my-aud" = { included_client_audience = "other-client" }
}

# Hardcoded claim
hardcoded_claim_mappers = {
  tenant = { claim_name = "tenant", claim_value = "ameria" }
}

# User attribute -> claim
user_attribute_mappers = {
  branch = { claim_name = "branch", user_attribute = "branch_code" }
}

# User realm roles -> claim
user_realm_role_mappers = {
  realm_roles = { claim_name = "realm_roles", multivalued = true }
}

# User client roles -> claim
user_client_role_mappers = {
  realm_mgmt = {
    claim_name                  = "resource_access.realm-management.roles"
    client_id_for_role_mappings = "realm-management"
    multivalued                 = true
  }
}

# Group membership
group_attribute_mappers = {
  groups = { claim_name = "groups" }
}

# Session note
user_session_note_mappers = {
  impersonator = { claim_name = "impersonator", session_note = "IMPERSONATOR_ID" }
}
```

### Generic protocol mappers

`generic_protocol_mappers` wraps `keycloak_generic_protocol_mapper` and accepts any
mapper type with any config keys. The map key becomes the mapper `name`; `realm_id`
and `client_id` are supplied by the module.

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `protocol_mapper` | `string` | n/a | Keycloak mapper type ID, e.g. `oidc-audience-mapper` (**required**) |
| `protocol` | `string` | `"openid-connect"` | `openid-connect` or `saml`; must match the client |
| `config` | `map(string)` | n/a | Mapper config passed to Keycloak verbatim (**required**) |

```hcl
generic_protocol_mappers = {
  "ltb.mycar.carloan" = {
    protocol_mapper = "oidc-audience-mapper"
    config = {
      "included.custom.audience"  = "ltb.mycar.carloan"
      "access.token.claim"        = "true"
      "id.token.claim"            = "true"
      "introspection.token.claim" = "true"
      "lightweight.claim"         = "false"
      "userinfo.token.claim"      = "true"
    }
  }
}
```

## Inputs (most common)

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `client_id` | `string` | n/a | clientId for the OpenID client (**required**) |
| `realm_id` | `string` | n/a | Realm the client belongs to (**required**) |
| `access_type` | `string` | `"CONFIDENTIAL"` | `CONFIDENTIAL`, `PUBLIC`, or `BEARER-ONLY` |
| `client_secret` | `string` | `null` | Auto-generated when null |
| `client_authenticator_type` | `string` | `"client-secret"` | Set to `client-jwt`/`client-secret-jwt` for signed-JWT auth |
| `standard_flow_enabled` | `bool` | `false` | Authorization Code flow |
| `direct_access_grants_enabled` | `bool` | `true` | ROPC (direct access) grant |
| `service_accounts_enabled` | `bool` | `true` | Client Credentials grant |
| `valid_redirect_uris` | `list(string)` | `null` | Allowed redirect URIs |
| `web_origins` | `list(string)` | `null` | Allowed CORS origins |
| `roles` | `list(string)` | `[]` | Client roles to create |
| `service_accounts_roles` | `list(string)` | `[]` | Realm role names assigned to the service account |
| `service_accounts_client_roles` | `list(string)` | `[]` | This client's own roles assigned to its service account |
| `service_accounts_role_ids` | `list(string)` | `[]` | Role IDs from other clients assigned to its service account |
| `default_client_scopes` | `list(string)` | `null` | Managed default scopes |
| `optional_client_scopes` | `list(string)` | `null` | Managed optional scopes |
| `extra_config` | `map(string)` | `{}` | Passthrough client attributes |
| `generic_protocol_mappers` | `map(object)` | `{}` | Any mapper type via `keycloak_generic_protocol_mapper` |

See [`variables.tf`](variables.tf) for the full set (token lifespans, logout,
consent, device flow, mappers, etc.).

## Outputs

| Name | Description |
|------|-------------|
| `client_id` / `client_uuid` | Internal Keycloak UUID of the client |
| `client_client_id` | The clientId string |
| `service_account_user_id` | Service-account user ID (null if disabled) |
| `resource_server_id` | Resource server ID when authorization is enabled |
| `role_id` | Map of client role name => role ID |
