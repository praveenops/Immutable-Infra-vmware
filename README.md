# Immutable-Infra-vmware

Wordpress-runtime: It creates the runtime environment with wordpress and mysql.

Immutable: It creates the VM with required packages( In this I have used apache2 with php7.0). From this vm we will create a snapshot.

Immutable-test: In this template you have to provide the template name which you created from Immutable VM.

Remember: you are checking only code immutablity..
