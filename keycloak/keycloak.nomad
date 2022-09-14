job "keycloak" {
    type = "service"

    datacenters = ["dc1"]

    group "keycloak" {

        network {
            port "http" {
                to = 8080
                static = 8080
            }
        }
        task "keycloak" {
            driver = "docker"
            config {
                image = "quay.io/keycloak/keycloak:19.0.2"
                command = "start-dev"
                ports = ["http"]
            }
            env {
                KEYCLOAK_ADMIN = "admin"
                KEYCLOAK_ADMIN_PASSWORD = "admin"
                KC_HTTP_RELATIVE_PATH = "/auth"
            }
            resources {
                memory = "512"
            }
        }
        service {
            name = "keycloak"
            port = "http"
            
        }
    }
}