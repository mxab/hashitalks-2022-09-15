terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "1.4.18"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.8.2"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "3.10.0"
    }
    vaultkeycloak = {
      source  = "Serviceware/vaultkeycloak"
      version = "0.3.10"
    }
  }
}
variable "keycloak_server_url" {
  type = string
}
provider "vault" {
  address = "http://localhost:8200"
  
  token   = "root"
}
provider "vaultkeycloak" {
  vault_address = "http://127.0.0.1:8200"
  vault_token   = "root"
}
provider "keycloak" {
  url       = var.keycloak_server_url
  client_id = "admin-cli"
  username  = "admin"
  password  = "admin"
}

data "terraform_remote_state" "realm" {
  backend = "local"

  config = {
    path = "../realm/terraform.tfstate"
  }
}

resource "vault_mount" "keycloak_client_secrets" {
  type = "keycloak-client-secrets"
  path = "keycloak-client-secrets"
}

module "keycloak_vault_config" {

  depends_on = [
    vault_mount.keycloak_client_secrets
  ]
  source              = "Serviceware/keycloak-client/vaultkeycloak"
  version             = "0.1.2"
  realm               = data.terraform_remote_state.realm.outputs.hashitalks_realm.realm
  vault_client_id     = "vault"
  vault_client_secret = "secret123"
}


resource "vaultkeycloak_secret_backend" "realm_backend" {
  depends_on = [
    vault_mount.keycloak_client_secrets,
    module.keycloak_vault_config
  ]
  client_id     = "vault"
  client_secret = "secret123"
  server_url    = var.keycloak_server_url
  realm         = data.terraform_remote_state.realm.outputs.hashitalks_realm.realm
  path          = "keycloak-client-secrets"

}
resource "vault_policy" "data_science_team" {
  name = "data-science-team"

  policy = <<EOT
path "secret/data-science/*" {
  capabilities = ["read"]
}
EOT
}