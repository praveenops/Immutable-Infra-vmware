#!/bin/bash



DB="wpadmin"
USER="wpuser"
PASS="Wpadmin@1234"

mysql -uroot -proot -e "CREATE DATABASE $DB CHARACTER SET utf8 COLLATE utf8_general_ci";
mysql -uroot -proot -e "CREATE USER $USER@'%' IDENTIFIED BY '$PASS'";
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON $DB.* TO '$USER'@'%'";
