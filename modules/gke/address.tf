module "address-lb" {
  source  = "terraform-google-modules/address/google"
  version = "0.1.0"

  names  = [ "lb-traefik-ext-ip"]
  global = true
}