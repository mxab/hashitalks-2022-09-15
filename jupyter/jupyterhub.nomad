job "jupyterhub" {
    type = "service"

    datacenters = ["dc1"]

    group "jupyterhub" {

        network {
            mode = "host"
            port "hub" {
                to = 8000
                static = 8000
            }
            port "api" {
                to = 8081
            }
        }
        task "jupyterhub" {
            driver = "docker"

            config {
                image = "ghcr.io/mxab/jupyterhub-nomad-spawner:main"
                auth_soft_fail = false

                args = [
                        "jupyterhub",
                        "-f",
                        "/local/jupyterhub_config.py",
                    ]
                ports = ["hub", "api"]

            }
            template {
                destination = "$${NOMAD_TASK_DIR}/nomad.env"
                env = true
                data = <<EOF

NOMAD_ADDR=http://host.docker.internal:4646
CONSUL_HTTP_ADDR=http://host.docker.internal:8500
    EOF
            }
            template {
                destination = "$${NOMAD_TASK_DIR}/jupyterhub_config.py"

                data = <<EOF

import os

c.ConfigurableHTTPProxy.debug = True


###########################################################
# JupyterHub Nomad Config
###########################################################
c.JupyterHub.spawner_class = "nomad-spawner"
c.JupyterHub.bind_url = "http://0.0.0.0:8000"
c.JupyterHub.hub_bind_url = "http://0.0.0.0:8081"

c.JupyterHub.hub_connect_url = f"http://{os.environ.get('NOMAD_IP_api')}:{os.environ.get('NOMAD_HOST_PORT_api')}"
c.JupyterHub.log_level = "DEBUG"
c.JupyterHub.allow_named_servers = True
c.JupyterHub.named_server_limit_per_user = 5

c.NomadSpawner.datacenters = ["dc1", "dc2", "dc3"]
c.NomadSpawner.csi_plugin_ids = ["nfs", "hostpath-plugin0"]
c.NomadSpawner.mem_limit = "2G"
c.NomadSpawner.common_images = ["jupyter/minimal-notebook:2022-08-20"]
c.NomadSpawner.vault_policies = ["data-science-team"]

######################################################################################################
######################################################################################################
# Keycloak Auth
######################################################################################################

{{ with service "keycloak" }}
{{ with index . 0 }}
from oauthenticator.generic import GenericOAuthenticator
c.JupyterHub.authenticator_class = GenericOAuthenticator




###########################################################
# This section is important for the demo
###########################################################

c.GenericOAuthenticator.client_id = 'jupyterhub'
c.GenericOAuthenticator.client_secret = 'SehrGeheim123'

c.GenericOAuthenticator.userdata_url='http://{{ .Address }}:{{ .Port }}/auth/realms/hashitalks/protocol/openid-connect/userinfo'

###########################################################
###########################################################
###########################################################




c.GenericOAuthenticator.oauth_callback_url = f"http://{os.environ.get('NOMAD_IP_hub')}:{os.environ.get('NOMAD_HOST_PORT_hub')}/hub/oauth_callback"
c.GenericOAuthenticator.login_service = 'keycloak'
c.GenericOAuthenticator.authorize_url= 'http://{{ .Address }}:{{ .Port }}/auth/realms/hashitalks/protocol/openid-connect/auth'
c.GenericOAuthenticator.token_url='http://{{ .Address }}:{{ .Port }}/auth/realms/hashitalks/protocol/openid-connect/token'

c.GenericOAuthenticator.username_key = 'preferred_username'
c.GenericOAuthenticator.userdata_params = {'state': 'state'}

c.GenericOAuthenticator.claim_groups_key = 'groups'
# users with `staff` role will be allowed
#c.GenericOAuthenticator.allowed_groups = ['staff']
# users with `administrator` role will be marked as admin

c.GenericOAuthenticator.admin_groups = ['admin']
c.GenericOAuthenticator.scope = ['openid', 'profile', 'roles']

{{ end }}
{{ end }}


                EOF


            }

            resources {
                memory = "512"
            }

        }

        service {
            name = "jupyter-hub"
            port = "hub"

            check {
                type     = "tcp"
                interval = "10s"
                timeout  = "2s"
            }

        }
        service {
            name = "jupyter-hub-api"
            port = "api"
            check {
                type     = "tcp"
                interval = "10s"
                timeout  = "2s"
            }

        }
    }
}

