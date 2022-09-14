variable "keycloak_server_url" {
  type = string
}
variable "jupyterhub_server_url" {
  type = string
}
provider "keycloak" {
  #base_path = ""
  url = var.keycloak_server_url

  realm     = "master"
  username  = "admin"
  password  = "admin"
  client_id = "admin-cli"
}


locals {
  client_id     = "jupyterhub"
  client_secret = "SehrGeheim123"
}

resource "keycloak_openid_client" "jupyterhub" {
  realm_id  = data.terraform_remote_state.realm.outputs.hashitalks_realm.realm
  client_id = local.client_id

  client_secret = local.client_secret

  enabled = true

  access_type = "CONFIDENTIAL"

  standard_flow_enabled = true
  root_url              = var.jupyterhub_server_url
  base_url              = "/"
  valid_redirect_uris = [
    "/hub/oauth_callback"
  ]
  web_origins = ["+"]
  admin_url   = "/"
}

resource "keycloak_role" "user" {
  realm_id  = data.terraform_remote_state.realm.outputs.hashitalks_realm.realm
  client_id = keycloak_openid_client.jupyterhub.id
  name      = "user"
}
resource "keycloak_role" "admin" {
  realm_id  = data.terraform_remote_state.realm.outputs.hashitalks_realm.realm
  client_id = keycloak_openid_client.jupyterhub.id
  name      = "admin"

  composite_roles = [
    keycloak_role.user.id
  ]
}


resource "keycloak_user" "alice" {

  realm_id   = data.terraform_remote_state.realm.outputs.hashitalks_realm.realm
  username   = "alice"
  first_name = "Alice"
  last_name  = "Smart"

  initial_password {
    value     = "alice"
    temporary = false
  }
}
resource "keycloak_user_roles" "user_roles" {
  realm_id = data.terraform_remote_state.realm.outputs.hashitalks_realm.realm
  user_id  = keycloak_user.alice.id

  role_ids = [
    keycloak_role.admin.id
  ]
}


resource "keycloak_user" "bob" {

  realm_id   = data.terraform_remote_state.realm.outputs.hashitalks_realm.realm
  username   = "bob"
  first_name = "Bobby"
  last_name  = "Bright"

  initial_password {
    value     = "bob"
    temporary = false
  }
}
resource "keycloak_user_roles" "user_roles_bob" {
  realm_id = data.terraform_remote_state.realm.outputs.hashitalks_realm.realm
  user_id  = keycloak_user.bob.id

  role_ids = [
    keycloak_role.admin.id
  ]
}


