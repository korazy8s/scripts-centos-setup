#!/bin/sh
yum -y install epel-release
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
yum -y update
yum -y install munin munin-node
sudo ln -s /usr/share/munin/plugins/apache_processes /etc/munin/plugins/apache_processes
sudo ln -s /usr/share/munin/plugins/apache_accesses /etc/munin/plugins/apache_accesses
sudo ln -s /usr/share/munin/plugins/apache_volume /etc/munin/plugins/apache_volume
systemctl enable munin-node
systemctl start munin-node

cat > /etc/httpd/conf.d/munin.conf <<EOL
<IfModule mod_status.c>
  ExtendedStatus On
  <Location /server-status>
    SetHandler server-status
    Order deny,allow
    Deny from all
    Allow from localhost ip6-localhost
  </Location>
</IfModule>
EOL

htpasswd /etc/munin/munin-htpasswd admin
