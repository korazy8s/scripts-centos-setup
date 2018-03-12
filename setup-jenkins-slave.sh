#!/bin/sh

# updates
yum -y update
yum -y install yum-cron
systemctl start yum-cron
sed -ie 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf

# install vmware tools
yum -y install open-vm-tools

# install remi repo
wget http://rpms.famillecollet.com/enterprise/7/remi/x86_64/remi-release-7.4-1.el7.remi.noarch.rpm
rpm -Uvh remi-release*rpm

# dependencies
yum -y group install "Development Tools"
yum -y install php-devel
yum -y install php-pear
yum -y install wget
yum -y install gcc gcc-c++ autoconf automake
yum -y install ant
yum -y install mysql
yum -y install epel-release
yum -y install libmcrypt
yum -y install php php-mysql
yum -y install php-mbstring
yum -y install php-mcrypt
yum -y install php-xml
yum -y install php-intl
yum -y install graphviz
yum -y install firewalld

# setup firewall
systemctl restart firewalld
firewall-cmd --zone=public --add-port=ssh/tcp --permanent
systemctl restart firewalld

# xdebug
# pecl install Xdebug
yum --enablerepo=remi -y install php-pecl-xdebug

# phpunit
wget -O phpunit.phar https://phar.phpunit.de/phpunit-4.8.9.phar
chmod +x phpunit.phar
mv -f phpunit.phar /usr/local/bin/phpunit

# phploc
wget -O phploc.phar https://phar.phpunit.de/phploc.phar
chmod +x phploc.phar
mv -f phploc.phar /usr/local/bin/phploc

# phpdox
wget -O phpDocumentor.phar http://www.phpdoc.org/phpDocumentor.phar
chmod +x phpDocumentor.phar
mv -f phpDocumentor.phar /usr/local/bin/phpdox

# phpcpd
wget -O phpcpd.phar https://phar.phpunit.de/phpcpd.phar
chmod +x phpcpd.phar
mv -f phpcpd.phar /usr/local/bin/phpcpd

# phpmd
wget -O phpmd.phar http://static.phpmd.org/php/latest/phpmd.phar
chmod +x phpmd.phar
mv -f phpmd.phar /usr/local/bin/phpmd

# pdepend
wget -O pdepend.phar http://static.pdepend.org/php/latest/pdepend.phar
chmod +x pdepend.phar
mv -f pdepend.phar /usr/local/bin/pdepend

# phpcs
wget -O phpcs.phar https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar
chmod +x phpcs.phar
mv -f phpcs.phar /usr/local/bin/phpcs

# s3cmd
wget -O /etc/yum.repos.d/s3tools.repo http://s3tools.org/repo/RHEL_6/s3tools.repo
yum -y install s3cmd

# aws cli
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# PHP.INI
sed -ri 's/^(memory_limit = )[0-9]+(M.*)$/\1'1024'\2/' /etc/php.ini
# [xdebug]
# zend_extension="/usr/lib64/php/modules/xdebug.so"
# xdebug.remote_enable = 1 

# yui compressor
wget -O /var/tmp/yuicompressor-2.4.7.zip https://github.com/downloads/yui/yuicompressor/yuicompressor-2.4.7.zip
unzip /var/tmp/yuicompressor-2.4.7.zip -d /var/tmp
rm -f /usr/share/java/yuicompressor-2.4.7.jar
rm -f /usr/share/java/yuicompressor.jar
cp -f /var/tmp/yuicompressor-2.4.7/build/yuicompressor-2.4.7.jar /usr/share/java/yuicompressor-2.4.7.jar
ln -s /usr/share/java/yuicompressor-2.4.7.jar /usr/share/java/yuicompressor.jar
chmod 777 /usr/share/java/yuicompressor*.jar
rm -rf /var/tmp/yuicompressor-2.4.7
rm -f /var/tmp/yuicompressor-2.4.7.zip

# show info
cat /etc/php.ini |grep memory_limit
firewall-cmd --state
firewall-cmd --list-all
ip addr
php --version
phpunit --version
