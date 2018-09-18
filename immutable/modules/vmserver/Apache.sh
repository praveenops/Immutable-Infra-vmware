
sudo apt-get update
sudo apt-get install apache2 apache2-utils unzip zip -y

sudo apt-get install software-properties-common -y

sudo add-apt-repository ppa:ondrej/php -y

sudo apt update
sudo apt install php7.1 libapache2-mod-php7.1 php7.1-common php7.1-mbstring php7.1-xmlrpc php7.1-soap php7.1-gd php7.1-xml php7.1-intl php7.1-mysql php7.1-cli php7.1-mcrypt php7.1-zip php7.1-curl -y


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

sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo a2dismod php7.0
sudo a2enmod php7.1

sudo systemctl enable apache2
sudo systemctl restart apache2.service
