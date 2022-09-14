#!/bin/bash

TF_VAR_keycloak_server_url="http://$(ipconfig getifaddr en0):8080"

TF_VAR_jupyterhub_server_url="http://$(ipconfig getifaddr en0):8000"
#export KEYCLOAK_URL

export TF_VAR_keycloak_server_url
export TF_VAR_jupyterhub_server_url