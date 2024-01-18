
data "hcloud_ssh_key" "ssh_key" {
  name = "${var.ssh_key_name}"
}

data "template_file" "cloud_init" {
	template = "${file("cloud-init.yml.tpl")}"

	vars = {
    tailscale_key = "${var.tailscale_auth_key}"
	}
}

# Allow only incoming ICMP and SSH
resource "hcloud_firewall" "k3s-firewall" {
  name = "k3s-firewall-${var.env_name}"

  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  labels = {
    label_1 = "${var.env_name}"
  }  
}

# private network
resource "hcloud_network" "internal-network" {
  name     = "internal-network"
  ip_range = "10.0.0.0/23"

  labels = {
    label_1 = "${var.env_name}"
  }
}

resource "hcloud_network_subnet" "network-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.internal-network.id
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

# Create a server
resource "hcloud_server" "k3s" {
  name        = "${var.env_name}-k3s"
  image       = "${var.node_image}"
  server_type = "${var.server_type}"
  ssh_keys    = [ data.hcloud_ssh_key.ssh_key.id ]
  location    = "${var.location}"

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }  

  network {
    network_id = hcloud_network.internal-network.id
    ip         = "10.0.1.6"
  }

  firewall_ids = [ hcloud_firewall.k3s-firewall.id ]

  user_data = "${data.template_file.cloud_init.rendered}"

  labels = {
    label_1 = "${var.env_name}"
  }
}

output "ipv4" {
  value = hcloud_server.k3s.ipv4_address
}

# certificate
resource "hcloud_managed_certificate" "lb_cert" {
  name         = "lb_cert"
  domain_names = ["*.${var.base_domain}", "${var.base_domain}"]
  labels = {
    label_1 = "${var.env_name}"
  }
}

# load balancer
resource "hcloud_load_balancer" "lb" {
  name               = "${var.env_name}-lb"
  load_balancer_type = "lb11"
  location           = "${var.location}"
  labels = {
    label_1 = "${var.env_name}"
  }  
}

# attach LB to network
resource "hcloud_load_balancer_network" "lb-network" {
  load_balancer_id = hcloud_load_balancer.lb.id
  network_id       = hcloud_network.internal-network.id
  ip               = "10.0.1.5"
}

# target for lb
resource "hcloud_load_balancer_target" "load_balancer_target" {
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb.id
  server_id        = hcloud_server.k3s.id
  use_private_ip   = true
}

resource "hcloud_load_balancer_service" "load_balancer_service" {
  load_balancer_id = hcloud_load_balancer.lb.id
  protocol         = "https"

  http {
    redirect_http   = true
    sticky_sessions = true
    cookie_name     = "${var.env_name}"
    certificates    = [hcloud_managed_certificate.lb_cert.id]
  }

  health_check {
    protocol = "http"
    port     = 80
    interval = 10
    timeout  = 5

    http {
      domain       = "${var.base_domain}"
      path         = "/dontexist" # just check if K3s is up and running
      response     = "404 page not found"
      tls          = true
      status_codes = ["404"]
    }
  }
}