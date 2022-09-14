terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "1.4.16"
    }
    keycloak = {
      source = "mrparkers/keycloak"
      version = "3.8.0"
    }
  }
}