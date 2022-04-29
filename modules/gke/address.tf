resource "google_compute_address" "load_balancer_ip" {
  name         = ""
  address_type = "EXTERNAL"
}