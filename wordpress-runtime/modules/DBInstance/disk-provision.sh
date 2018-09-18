mkdir mysqldb
sudo yes | mkfs.ext4 -L datapartition /dev/sdb
sudo mount /dev/sdb /home/ubuntu/mysqldb
