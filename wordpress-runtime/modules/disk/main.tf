resource "vsphere_virtual_disk" "dbdisk" {
  size       = "10"
  type       = "thin"
  vmdk_path  = "database.vmdk"
  datastore  = "datastore1"
  datacenter = "DC1"
}
