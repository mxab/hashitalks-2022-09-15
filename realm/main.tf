terraform {
  required_providers {
    
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "3.10.0"
    }
  }
}
variable "keycloak_server_url" {
  type = string
}

provider "keycloak" {
  url       = var.keycloak_server_url
  client_id = "admin-cli"
  username  = "admin"
  password  = "admin"
}

locals {
  realm = "hashitalks"
}

resource "keycloak_realm" "hashitalks" {
  realm = local.realm
}

output "hashitalks_realm" {
  value = keycloak_realm.hashitalks
}
