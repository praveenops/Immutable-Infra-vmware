data "vsphere_datacenter" "dc" {
  name = "DC1"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "test"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "Ubuntu-16-template"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "Apache"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  guest_id = "ubuntu64Guest"

  enable_disk_uuid = "true"

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  # We cannot swith from thick disk to thin disk during cloning.
  disk {
    label = "disk1"
    size  = 8
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "apache"
        domain    = "praveenops.com"
      }

      network_interface {
        ipv4_address = "172.16.13.70"
        ipv4_netmask = 24
      }

      ipv4_gateway    = "172.16.13.1"
      dns_server_list = ["8.8.8.8"]
      dns_suffix_list = ["8.8.8.8"]
    }
  }

  provisioner "file" {
    source      = "Apache.sh"
    destination = "/home/ubuntu/Apache.sh"
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    password = "1234"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = "172.16.13.70"
      user     = "ubuntu"
      password = "1234"
    }

    inline = [
      "echo ${var.pw} |sudo -S apt-get update",
      "sudo chmod +x /home/ubuntu/Apache.sh && sudo bash -x /home/ubuntu/Apache.sh",
    ]
  }
}
