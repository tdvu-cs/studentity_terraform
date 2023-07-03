terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file("credentials.json")

  project = "studentity-372802"
  region  = "australia-southeast1"
  zone    = "australia-southeast1-b"
}

resource "google_compute_network" "vpc_network" {
  name = "studentity-vpc"
}

resource "google_compute_instance" "vm_instance" {
  name         = "studentity-frontend"
  machine_type = "f1-micro"
  tags = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}
