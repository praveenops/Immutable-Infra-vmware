#
sudo apt-get update
sudo apt-get install apache2 apache2-utils unzip zip -y

sudo apt-get install software-properties-common -y
#sudo add-apt-repository ppa:ondrej/php
sudo add-apt-repository ppa:ondrej/php -y

sudo apt update
sudo apt install php7.1 libapache2-mod-php7.1 php7.1-common php7.1-mbstring php7.1-xmlrpc php7.1-soap php7.1-gd php7.1-xml php7.1-intl php7.1-mysql php7.1-cli php7.1-mcrypt php7.1-zip php7.1-curl -y

sudo echo '/dev/sdb /var/www/html ext4 defaults 0 0' >> /etc/fstab
sudo mount -a

#cat << EOF > //etc/php/7.1/apache2/php.ini
#file_uploads = On
#allow_url_fopen = On
#memory_limit = 256M
#upload_max_filesize = 100M
#max_execution_time = 360
#date.timezone = America/Chicago
#EOF

#Downloading and extracting zip file to document root.
cd /tmp
curl  https://wordpress.org/latest.zip --output latest.zip
unzip /tmp/latest.zip -d /var/www/html/
sudo cp -rvf /var/www/html/wordpress/* /var/www/html
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php


sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# Create a WordPress config file
sudo touch /etc/apache2/sites-available/wordpress.conf
cat << EOF > /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
     ServerAdmin admin@example.com
     DocumentRoot /var/www/html
     ServerName localhost

     <Directory /var/www/html>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
     </Directory>

     ErrorLog ${APACHE_LOG_DIR}/error.log
     CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
EOF

cat << EOF > /etc/apache2/mods-available/dir.conf
<IfModule mod_dir.c>
	     DirectoryIndex index.php index.html index.cgi index.pl index.php index.xhtml index.htm
</IfModule>
EOF

#set database details with perl find and replace
sudo sed -i "s/database_name_here/wpadmin/g" /var/www/html/wp-config.php
sudo sed -i "s/username_here/wpuser/g" /var/www/html/wp-config.php
sudo sed -i "s/password_here/Wpadmin@1234/g" /var/www/html/wp-config.php
sudo sed -i "s/localhost/172.16.13.75/g" /var/www/html/wp-config.php

sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo a2dismod php7.0
sudo a2enmod php7.1

sudo systemctl enable apache2
sudo systemctl restart apache2.service
