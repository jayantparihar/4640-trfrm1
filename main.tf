terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "ACIT-4640" {
  name = "ACIT-4640"
}

data "digitalocean_project" "lab_project" {
  name = "first-project"
}

#create a new tag
resource "digitalocean_tag" "do_tag" {
  name = "web"
}

#create a new vpc

resource "digitalocean_vpc" "web_vpc" {
  name   = "firstproject"
  region = "sfo3"
}

#create a new web droplet

resource "digitalocean_droplet" "web" {
  image    = "rockylinux-9-x64"
  name     = "web-1"
  tags     = [digitalocean_tag.do_tag.id]
  region   = "sfo3"
  size     = "s-1vcpu-512mb-10gb"
  ssh_keys = [data.digitalocean_ssh_key.ACIT-4640.id]
  vpc_uuid = digitalocean_vpc.web_vpc.id
}

#add new web-1 droplet to first-project

resource "digitalocean_project_resources" "project_attach" {
  project = data.digitalocean_project.lab_project.id
  resources = [
    digitalocean_droplet.web.urn
  ]
}

output "server_ip" {
  value = digitalocean_droplet.web.ipv4_address
}
