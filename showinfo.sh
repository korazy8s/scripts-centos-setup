#!/bin/sh

# show host information
hostnamectl

#show network information
ip addr show

# show ip ports
netstat -tulpn

# show firewall status
firewall-cmd --state
firewall-cmd --list-all

# show apache status
systemctl status httpd

# show php information
php --version
phpunit --version

# show selinux status
sestatus
