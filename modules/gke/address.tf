resource "google_compute_address" "load_balancer_ip" {
  name         = "lb-external-ip"
  address_type = "EXTERNAL"
}