# storage for K3s data
resource "hcloud_volume" "k3s-storage" {
  name       = "k3s-volume"
  size       = 10
  server_id  = hcloud_server.k3s.id
  automount  = true
  format     = "ext4"
  delete_protection = "false"

  connection {
    type="ssh"
    host = "${hcloud_server.k3s.ipv4_address}"
    agent = true
  }

  provisioner "remote-exec" {
    inline = ["/bin/bash /root/bootstrap.sh ${hcloud_volume.k3s-storage.linux_device}"]
  }
}