terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name                    = "studentity-vpc"
  auto_create_subnetworks = false

}

resource "google_compute_subnetwork" "subnet-1" {
  name          = "subnet-1"
  ip_cidr_range = "10.0.10.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  project = var.project
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  project = var.project
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-https" {
  name    = "allow-https"
  project = var.project
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-internal" {
  name    = "allow-internal"
  project = var.project
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = [google_compute_subnetwork.subnet-1.ip_cidr_range]
}

# resource "google_compute_address" "external_ip" {
#   name    = "static-app-ip"
#   project = var.project
#   region  = var.region
# }

data "google_compute_address" "existing_static_ip" {
  name    = "static-app-ip"
  project = var.project
  region  = var.region
}

resource "google_compute_instance" "compute_instance" {
  name         = "studentity-app"
  machine_type = "e2-micro"
  zone         = var.zone
  project      = var.project
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  metadata_startup_script = <<-SCRIPT
    #! /bin/bash
    apt update
    apt -y install apache2
    cat <<EOF > /var/www/html/index.html
    <html><body><p>I love you.</p></body></html>
    EOF
  SCRIPT

  network_interface {
    subnetwork = google_compute_subnetwork.subnet-1.id
    access_config {
      nat_ip = data.google_compute_address.existing_static_ip.address
    }
  }
}

