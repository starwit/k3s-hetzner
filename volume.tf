# storage for K3s data
resource "hcloud_volume" "k3s-storage" {
  name       = "k3s-volume"
  size       = 10
  server_id  = "${hcloud_server.k3s.id}"
  automount  = true
  format     = "ext4"
}