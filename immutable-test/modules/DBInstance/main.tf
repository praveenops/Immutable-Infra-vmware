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
  name          = "apache2"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "${var.vmname}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  guest_id         = "ubuntu64Guest"
  enable_disk_uuid = "true"

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  # We cannot swith from thick disk to thin disk during cloning.
  disk {
    label = "datadisk"
    size  = 8
  }

  disk {
    attach       = "true"
    path         = "database.vmdk"
    label        = "sharedvolume"
    unit_number  = "2"
    datastore_id = "${data.vsphere_datastore.datastore.id}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "poc"
        domain    = "praveenops.com"
      }

      network_interface {
        ipv4_address = "${var.ipaddress}"
        ipv4_netmask = 24
      }

      ipv4_gateway    = "172.16.13.1"
      dns_server_list = ["8.8.8.8"]
      dns_suffix_list = ["8.8.8.8"]
    }
  }

  provisioner "file" {
    source      = "mount.sh"
    destination = "/home/ubuntu/mount.sh"
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    password = "1234"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = "172.16.13.74"
      user     = "ubuntu"
      password = "1234"
    }

    inline = [
      "echo ${var.pw} |sudo -S apt-get update",
      "sudo chmod +x /home/ubuntu/mount.sh && sudo bash -x /home/ubuntu/mount.sh",
    ]
  }
}
