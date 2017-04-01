#!/bin/sh

# set variables
CERTC=CA
CERTST=Manitoba
CERTO=
CERTLOCALITY=
CERTCOMMONNAME=
CERTORG=
CERTEMAIL=root@localhost

# add webmin to yum repos
cat > /etc/yum.repos.d/webmin.repo <<EOL
[Webmin]
name=Webmin Distribution Neutral
#baseurl=http://download.webmin.com/download/yum
mirrorlist=http://download.webmin.com/download/yum/mirrorlist
enabled=1
EOL

# add webmin key to yum
rpm --import http://www.webmin.com/jcameron-key.asc

# update yum
yum check-update

# install latest updates
yum -y update

# setup automatic updates manager
yum -y install yum-cron
systemctl start yum-cron
sed -ie 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf

# set machine info
hostnamectl set-hostname ${HOSTNAME}

# install dependencies
yum -y install wget
yum -y install firewalld

# install vmware tools
yum -y install open-vm-tools

# start and setup firewall
systemctl restart firewalld
firewall-cmd --zone=public --add-port=ssh/tcp --permanent
firewall-cmd --add-port=10000/tcp --permanent
systemctl restart firewalld

# install
yum -y install webmin
chkconfig webmin on
service webmin start
