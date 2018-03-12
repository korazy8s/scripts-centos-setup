#!/bin/sh

# set variables
CERTC=CA
CERTST=Manitoba
CERTO=
CERTLOCALITY=
CERTCOMMONNAME=
CERTORG=
CERTEMAIL=root@localhost

# install latest updates
yum -y update

# setup automatic updates manager
yum -y install yum-cron
systemctl start yum-cron
sed -ie 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf

# install vmware tools
yum -y install open-vm-tools

# install apache
yum -y install httpd

# install dependencies
yum -y group install "Development Tools"
yum -y install openssl
yum -y install libmcrypt
yum -y install php php-devel php-pear php-mysql php-mbstring php-mcrypt php-xml php-intl
yum -y install wget
yum -y install epel-release
yum -y install graphviz
yum -y install mod_ssl

# change PHP.INI to max memory of 1GB
sed -ri 's/^(memory_limit = )[0-9]+(M.*)$/\1'1024'\2/' /etc/php.ini

# start and setup firewall
systemctl restart firewalld
firewall-cmd --zone=public --add-port=http/tcp --permanent
firewall-cmd --zone=public --add-port=https/tcp --permanent
systemctl restart firewalld

# create ssl certs
SUBJ="
C=${CERTC}
ST=${CERTST}
O=${CERTO}
localityName=${CERTLOCALITY}
commonName=${CERTCOMMONNAME}
organizationalUnitName=${HOSTNAME}
emailAddress=${CERTEMAIL}
"
mkdir -p /var/certs
rm -f /var/certs/www-cert.crt
rm -f /var/certs/www-cert.key
openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -x509 -newkey rsa:2048 -days 1820 -nodes -out /var/certs/www-cert.crt -keyout /var/certs/www-cert.key
chmod 755 /var/certs/www-cert.crt
chmod 755 /var/certs/www-cert.key

# setup apache
mkdir -p /var/www/html/public

# configure apache host with ssl certs
cat > /etc/httpd/conf.d/default.conf <<EOL
<VirtualHost *:443>
  ServerName ${HOSTNAME}
  ServerAlias ${HOSTNAME}
  DocumentRoot /var/www/html/public
  <Directory /var/www/html/public/>
    Options -Indexes +FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>
  SSLEngine on
  SSLCertificateFile /var/certs/www-cert.crt
  SSLCertificateKeyFile /var/certs/www-cert.key
</VirtualHost>
EOL

# configure .htaccess
cat > /var/www/html/public/.htaccess <<EOL
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^ index.php [L]
EOL

# setup phpinfo
cat > /var/www/html/public/phpinfo.php <<EOL
<?php phpinfo() ?>
EOL

# remove apache welcome page
cat > /etc/httpd/conf.d/welcome.conf <<EOL
# disabled
EOL

# start apache service
systemctl enable httpd

# disable SELinux
cat > /etc/selinux/config <<EOL
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of three two values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
EOL

systemctl restart httpd
