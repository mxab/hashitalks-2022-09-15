

provider "nomad" {
  address = "http://localhost:4646"
}
resource "nomad_job" "jupyterhub" {
  jobspec = templatefile("jupyterhub.nomad", {

  })
}

data "terraform_remote_state" "realm" {
  backend = "local"

  config = {
    path = "../realm/terraform.tfstate"
  }
}

