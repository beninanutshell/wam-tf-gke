resource "google_compute_address" "load_balancer_ip" {
  name         = "lb-external-ip"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}