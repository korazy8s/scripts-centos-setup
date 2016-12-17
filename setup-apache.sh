#!/bin/sh

# set variables
HOSTNAME=www1
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
yum -y install php
yum -y install php-devel
yum -y install php-pear
yum -y install wget
yum -y install epel-release
yum -y install libmcrypt
yum -y install php-mysql
yum -y install php-mbstring
yum -y install php-mcrypt
yum -y install php-xml
yum -y install php-intl
yum -y install graphviz
yum -y install mod_ssl
yum -y install firewalld

# change PHP.INI to max memory of 1GB
sed -ri 's/^(memory_limit = )[0-9]+(M.*)$/\1'1024'\2/' /etc/php.ini

# start and setup firewall
systemctl restart firewalld
firewall-cmd --zone=public --add-port=ssh/tcp --permanent
firewall-cmd --zone=public --add-port=http/tcp --permanent
firewall-cmd --zone=public --add-port=https/tcp --permanent
systemctl restart firewalld

# set machine info
hostnamectl set-hostname ${HOSTNAME}

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
mkdir /var/certs
rm -f /var/certs/www-cert.crt
rm -f /var/certs/www-cert.key
openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -x509 -sha256 -days 1820 -nodes -out /var/certs/www-cert.crt -keyout /var/certs/www-cert.key
chmod 400 /var/certs/www-cert.crt
chmod 400 /var/certs/www-cert.key

####################
## TODO: configure apache host with ssl certs
####################
cat > /etc/httpd/conf.d/default.conf <<EOL
NameVirtualHost *:443
<VirtualHost *:443>
    DocumentRoot "/var/www/html"
    SSLEngine on
    SSLOptions +StrictRequire
    <Directory />
        SSLRequireSSL
    </Directory>
    SSLProtocol -all +TLSv1 +SSLv3
    SSLCipherSuite HIGH:MEDIUM:!aNULL:+SHA1:+MD5:+HIGH:+MEDIUM
    SSLRandomSeed startup file:/dev/urandom 1024
    SSLRandomSeed connect file:/dev/urandom 1024
    SSLSessionCache shm:/usr/local/apache2/logs/ssl_cache_shm
    SSLSessionCacheTimeout 600    
    SSLCertificateFile /var/certs/www-cert.crt
    SSLCertificateKeyFile /var/certs/www-cert.key
    SSLVerifyClient none
    SSLProxyEngine off
    <IfModule mime.c>
        AddType application/x-x509-ca-cert      .crt
        AddType application/x-pkcs7-crl         .crl
    </IfModule>
    SetEnvIf User-Agent ".*MSIE.*" \  
      nokeepalive ssl-unclean-shutdown \  
      downgrade-1.0 force-response-1.0
</VirtualHost>
EOL

# start apache service
systemctl start httpd
systemctl enable httpd
# if run script more than once, restart for changes
systemctl restart httpd

# show info
cat /etc/php.ini |grep memory_limit
echo
firewall-cmd --state
firewall-cmd --list-all
echo
ip addr
echo
php --version
echo
hostnamectl status
echo
systemctl status httpd
echo
