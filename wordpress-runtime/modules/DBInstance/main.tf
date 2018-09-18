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
    label          = "datadisk"
    size           = 20
    keep_on_remove = "true"
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
        domain    = "praveenmali.com"
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
    source      = "/home/praveenm/my-docs/POC/wordpress-runtime/modules/DBInstance/disk-provision.sh"
    destination = "/home/ubuntu/disk-provision.sh"
  }

  provisioner "file" {
    source      = "/home/praveenm/my-docs/POC/wordpress-runtime/modules/DBInstance/wordpress.sh"
    destination = "/home/ubuntu/wordpress.sh"
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
      "sudo chmod +x /home/ubuntu/wordpress.sh && sudo bash -x /home/ubuntu/wordpress.sh",
      "sudo chmod +x /home/ubuntu/disk-provision.sh && sudo bash -x /home/ubuntu/disk-provision.sh",
    ]
  }
}

resource "vsphere_virtual_machine" "DB01" {
  name             = "poc-db"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  guest_id = "ubuntu64Guest"

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  # We cannot swith from thick disk to thin disk during cloning.
  disk {
    label            = "DBDisk01"
    size             = "20"
    datastore_id     = "${data.vsphere_datastore.datastore.id}"
    thin_provisioned = "true"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "poc-db"
        domain    = "praveenmali.com"
      }

      network_interface {
        ipv4_address = "172.16.13.75"
        ipv4_netmask = 24
      }

      ipv4_gateway    = "172.16.13.1"
      dns_server_list = ["8.8.8.8"]
      dns_suffix_list = ["8.8.8.8"]
    }
  }

  provisioner "file" {
    source      = "/home/praveenm/my-docs/POC/wordpress-runtime/modules/DBInstance/mysqlinstall.sh"
    destination = "/home/ubuntu/mysqlinstall.sh"
  }

  provisioner "file" {
    source      = "/home/praveenm/my-docs/POC/wordpress-runtime/modules/DBInstance/mysqldb.sh"
    destination = "/home/ubuntu/mysqldb.sh"
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    password = "1234"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = "172.16.13.75"
      user     = "ubuntu"
      password = "1234"
    }

    inline = [
      "echo ${var.pw} |sudo -S apt-get update",
      "sudo chmod +x /home/ubuntu/mysqlinstall.sh && sudo bash -x /home/ubuntu/mysqlinstall.sh",
      "sudo chmod +x /home/ubuntu/mysqldb.sh && sudo bash -x /home/ubuntu/mysqldb.sh",
    ]
  }
}
