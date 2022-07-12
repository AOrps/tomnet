terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.27.0"
    }
  }
}

provider "google" {
  credentials = file(var.creds)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "google_compute_network" "vpc_network" {
  name                    = "tomnet"
  auto_create_subnetworks = false
}

# First Subnet with hacker machines
resource "google_compute_subnetwork" "hack" {
  name          = "corp"
  ip_cidr_range = "10.0.0.0/28"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# Second subnet with security tools
resource "google_compute_subnetwork" "tool" {
  name          = "tool"
  ip_cidr_range = "10.0.0.16/28"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "default" {
  name = "firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = [ "22" ]
  }

  source_tags = ["ssh"]
  source_ranges = ["0.0.0.0/0"]
}


resource "google_compute_instance" "vm_instance1" {
  name         = "tn-hack-machine1"
  machine_type = "f1-micro"
  tags         = ["hack"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.hack.name
    access_config {
    }
  }
}

resource "google_compute_instance" "vm_instance2" {
  name         = "tn-hack-machine2"
  machine_type = "f1-micro"
  tags         = ["hack"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.hack.name
    access_config {
    }
  }
}

resource "google_compute_instance" "vm_instance3" {
  name         = "tn-tool-machine1"
  machine_type = "f1-micro"
  tags         = ["tool"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.hack.name
    access_config {
    }
  }
}