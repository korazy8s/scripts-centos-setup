#!/bin/sh

sudo yum -y install libtool zlib-devel curl-devel openssl-devel httpd-devel apr-devel apr-util-devel apr mysql-devel

wget http://www.redmine.org/releases/redmine-3.3.2.tar.gz
wget https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.1.tar.gz
wget https://rubygems.org/rubygems/rubygems-2.6.11.tgz

tar zxvf ruby-2.4.1.tar.gz
tar zxvf rubygems-2.6.11.tgz
tar zxvf redmine-3.3.2.tar.gz

cd ./ruby-2.4.1
./configure
make
make install
cd ..

cd ./rubygems-2.6.11
ruby setup.rb
gem -v
which gem
cd ..

gem install passenger
passenger-install-apache2-module

wget http://www.fastcgi.com/dist/mod_fastcgi-current.tar.gz
tar -zxvf mod_fastcgi-current.tar.gz
cd ./mod_fastcgi-2.4.6
cp Makefile.AP2 Makefile 
make top_dir=/usr/lib/httpd
make install top_dir=/usr/lib/httpd
cd ..

# setup apache
rm -f /etc/httpd/conf.d/*.conf
mkdir -p /var/www/html

# setup apache httpd.conf
cat > /etc/httpd/conf/httpd.conf <<EOL
ServerRoot "/etc/httpd"
Listen 80
Include conf.modules.d/*.conf
User apache
Group apache
ServerAdmin root@localhost
#ServerName www.example.com:80
<Directory />
    AllowOverride none
    Require all denied
</Directory>
DocumentRoot "/var/www/html"
<Directory "/var/www">
    AllowOverride None
    # Allow open access:
    Require all granted
</Directory>
<Directory "/var/www/html">
  Options Indexes FollowSymLinks
  AllowOverride None
  Require all granted
</Directory>
<IfModule dir_module>
  DirectoryIndex index.html
</IfModule>
<Files ".ht*">
  Require all denied
</Files>
ErrorLog "logs/error_log"
LogLevel warn
<IfModule log_config_module>
  LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
  LogFormat "%h %l %u %t \"%r\" %>s %b" common
  <IfModule logio_module>
    # You need to enable mod_logio.c to use %I and %O
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
  </IfModule>
  #CustomLog "logs/access_log" common
  CustomLog "logs/access_log" combined
</IfModule>
<IfModule alias_module>
  ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
</IfModule>
<Directory "/var/www/cgi-bin">
  AllowOverride None
  Options None
  Require all granted
</Directory>
<IfModule mime_module>
  TypesConfig /etc/mime.types
  #AddType application/x-gzip .tgz
  #AddEncoding x-compress .Z
  #AddEncoding x-gzip .gz .tgz
  AddType application/x-compress .Z
  AddType application/x-gzip .gz .tgz
  #AddHandler cgi-script .cgi
  #AddHandler type-map var
  AddType text/html .shtml
  AddOutputFilter INCLUDES .shtml
</IfModule>
AddDefaultCharset UTF-8
<IfModule mime_magic_module>
  MIMEMagicFile conf/magic
</IfModule>
#ErrorDocument 500 "The server made a boo boo."
#ErrorDocument 404 /missing.html
#ErrorDocument 404 "/cgi-bin/missing_handler.pl"
#ErrorDocument 402 http://www.example.com/subscription_info.html
#EnableMMAP off
EnableSendfile on
IncludeOptional conf.d/*.conf
EOL

cat > /etc/httpd/conf.d/mod_fastcgi.conf <<EOL
LoadModule fastcgi_module modules/mod_fastcgi.so
<IfModule mod_fastcgi.c>
  FastCgiIpcDir /tmp/fcgi_ipc/
</IfModule>
EOL

cat > /etc/httpd/conf.d/mod_passenger.conf <<EOL
LoadModule passenger_module /usr/local/lib/ruby/gems/2.4.0/gems/passenger-5.1.2/buildout/apache2/mod_passenger.so
<IfModule mod_passenger.c>
  PassengerRoot /usr/local/lib/ruby/gems/2.4.0/gems/passenger-5.1.2
  PassengerDefaultRuby /usr/local/bin/ruby
</IfModule>
EOL

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
