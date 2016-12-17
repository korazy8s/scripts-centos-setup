#/bin/sh

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

# install
yum -y install webmin
chkconfig webmin on
service webmin start

# open firewall
firewall-cmd --add-port=10000/tcp --permanent
systemctl restart firewalld
