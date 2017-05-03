# variables. These are loaded from terraform.tfvars
variable "domain" {}
variable "project_id" {}
variable "project_region" {}
variable "gcp_credentials" {}
variable "email" {}


# The provider configuration.
provider "google" {
  credentials = "${file(var.gcp_credentials)}"
  project     = "${var.project_id}"
  region      = "${var.project_region}"
}


# The DNS for our system.
resource "google_dns_managed_zone" "dns" {
  name        = "project-zone"
  dns_name    = "${var.domain}."
  description = "Our project DNS zone"
}


# provide some zone data to our config
data "google_compute_zones" "available" {}


# firewall rule for web
resource "google_compute_firewall" "default" {
  name    = "default-allow-web-traffic"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["web-server"]
}


# Our Go CD server.
resource "google_compute_instance" "gocd" {
  name         = "gocd"
  machine_type = "n1-standard-1"
  zone         = "${data.google_compute_zones.available.names[0]}"

  tags = ["web-server"]

  disk {
    image = "debian-cloud/debian-8"
  }

  metadata = {
    dns = "gocd.${var.domain}"
    email = "${var.email}"
  }
  
  metadata_startup_script = "${file("infrastructure-scripts/gocd-init.sh")}"

  network_interface {
    network       = "default"
    access_config = {}
  }

  service_account {
    scopes = ["useraccounts-ro", "storage-ro", "logging-write",
              "monitoring-write", "service-management", "service-control",
              "https://www.googleapis.com/auth/ndev.clouddns.readwrite"]
  }
}


# The DNS record set for the Go CD server.
resource "google_dns_record_set" "gocd" {
  name = "gocd.${google_dns_managed_zone.dns.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.dns.name}"

  rrdatas = ["${google_compute_instance.gocd.network_interface.0.access_config.0.assigned_nat_ip}"]
}