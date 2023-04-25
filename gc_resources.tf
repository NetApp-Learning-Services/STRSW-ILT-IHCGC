########################################################
# VPC Networks (node-vpc, ha-vpc, cluster-vpc, data-vpc)
########################################################
# vpc network for node-vpc
resource "google_compute_network" "node-vpc" {
  name                    = "node-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "subnet1"
  ip_cidr_range = "10.221.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.node-vpc.id
}

# vpc network for ha-vpc
resource "google_compute_network" "ha-vpc" {
  name                    = "ha-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "subnet2" {
  name          = "subnet2"
  ip_cidr_range = "10.222.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.ha-vpc.id
}

# vpc network for cluster-vpc
resource "google_compute_network" "cluster-vpc" {
  name                    = "cluster-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "subnet3" {
  name          = "subnet3"
  ip_cidr_range = "10.223.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.cluster-vpc.id
}

# vpc network for data-vpc
resource "google_compute_network" "data-vpc" {
  name                    = "data-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "subnet4" {
  name          = "subnet4"
  ip_cidr_range = "10.224.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.data-vpc.id
}
##################################################
# Compute Instance (linux-private, windows-public)
##################################################
# Create a single linux-private instance
resource "google_compute_instance" "linux-private" {
  name         = "linux-private"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
	  size  = 10
      type  = "pd-balanced"
    }
  }

  # Install Updates
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -y; sudo apt-get install nfs-common -y"
  #Install Network
  
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1.id

  }
}
# Create a single windows-public instance
resource "google_compute_instance" "windows-public" {
  name         = "windows-public"
  machine_type = "e2-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "windows-server-2019-dc-v20221214"
	  size  = 50
      type  = "pd-balanced"
    }
  }
  
#Install Network
  
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}
###############################################################
# Firewall Rules (ssh,DNS,http,https,rdp - UPD 500,4500 - icmp)
###############################################################
resource "google_compute_firewall" "rules" {
  name = "firewall-rules"
  allow {
    ports    = ["22", "53", "80", "443", "3389"]
    protocol = "tcp"
  }
  allow {
    ports    = ["500", "4500"]
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.node-vpc.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
}