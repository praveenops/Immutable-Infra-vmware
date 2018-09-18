provider "vsphere" {
  vsphere_server       = "${var.vsphere_vcenter}"
  user                 = "${var.vsphere_user}"
  password             = "${var.vsphere_password}"
  allow_unverified_ssl = true
}

module "Instance" {
  source = "modules/vmserver"
}
