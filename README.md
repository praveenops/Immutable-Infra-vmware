# This document is not yet polished. I am just updating readme for my refernce.

# Immutable-Infra-vmware
1) Bake runtime environment to test server immutablity. So run the the teplate

$cd /home/praveenm/my-docs/POC/wordpress-runtime/

terraform apply

This creates the followig:
  -> It provisions a disk and it formats it in ext4, then mounts to /var/www/html
  -> It spins web and DB server.

2) Next prepare the webserver with necessary packages, which are configured in runtime. This I am cooking it seperately because i dont want to ruine the runtime environment.

$cd /home/praveenm/my-docs/POC/immutable/

terraform apply.

3) Now we gonna create a template name called Apache to use per environment or we can use when ever we want to make it.

-> To do this stop vm and create template from the launched VM.

4) It's time to prove server immutablity.

Now go to wordpress-runtime path:

$cd /home/praveenm/my-docs/POC/wordpress-runtime/

terraform destroy -target=module.Instance.vsphere_virtual_machine.vm

Note: we have to remember the IP address of original instance. so that it can not tamper the dns configuration in network.

5) Now we are launching a instance from new baked apache instance with the original IP address.

$cd /home/praveenm/my-docs/POC/immutable-test

Note: maintain VM size same in all templates.

We can not use/attach the existing disk(.vmdk) 

Questions:

Now What if the code update happenning everyday?

Since we are using external disk. we no need to worry about this and the same is applicable to Databases too.

