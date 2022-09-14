

```sh
./vault.sh

consul agent -dev
nomad agent -dev -network-interface='{{ GetPrivateInterfaces | attr "name" }}' -config nomad/nomad.conf

vault server -dev -dev-root-token-id=root  -dev-plugin-dir=vault/plugins -dev-listen-address=0.0.0.0:8200 -config vault/vault.conf

source env.sh # works only on mac

cd keycloak
terraform init
terraform apply -auto-approve
cd ..
# wait until keycloak is available


cd realm

terraform init
terraform apply -auto-approve
cd ..

cd vault
terraform init
terraform apply -auto-approve
cd ..

cd jupyter
terraform init
terraform apply -auto-approve
cd ..



```