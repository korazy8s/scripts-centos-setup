#!/bin/sh

# add mariadb to yum repos
cat > /etc/yum.repos.d/MariaDB.repo <<EOL
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOL

# install mariadb
yum -y install MariaDB-server MariaDB-client

# configure firewall
systemctl restart firewalld
firewall-cmd --add-port=3306/tcp --permanent
systemctl restart firewalld

# start db engine
systemctl start mariadb
systemctl enable mariadb
systemctl status mariadb

# secure db engine
mysql_secure_installation

# show info
mysql -V
mysqld --print-defaults
