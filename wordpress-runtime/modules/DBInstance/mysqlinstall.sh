# Download and Install the Latest Updates for the OS
sudo apt update
sudo apt-get install debconf-utils -y

# Install MySQL Server in a Non-Interactive mode. Default root password will be "root"

sudo echo "mysql-server-5.7 mysql-server/root_password password root" | sudo debconf-set-selections
sudo echo "mysql-server-5.7 mysql-server/root_password_again password root" | sudo debconf-set-selections
sudo apt install mysql-server-5.7  -y

# Change MySQL Listening IP Address from local 127.0.0.1 to All IPs 0.0.0.0

sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf

# Update mysql Table root record to accept incoming remote connections

sudo mysql -uroot -proot -e 'USE mysql; UPDATE `user` SET `Host`="%" WHERE `User`="root" AND `Host`="localhost"; DELETE FROM `user` WHERE `Host` != "%" AND `User`="root"; FLUSH PRIVILEGES;'

# Restart MySQL Service
sudo service mysql restart

# End Script
echo "Please do run mysql_secure_installation to Secure your MySQL Installation."
echo "Thanks for using this script."
