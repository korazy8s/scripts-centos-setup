#!/bin/sh

# show host information
hostnamectl
lsb_release -a
cat /etc/redhat-release
cat /etc/os-release
uname -a
dpkg -l | grep linux-image
echo

#show network information
ip addr show
echo

# show ip ports
netstat -tulpn
echo

# show firewall status
firewall-cmd --state
firewall-cmd --list-all
echo

# show apache status
systemctl status httpd
echo

# show php information
php --version
echo

# show selinux status
sestatus
echo
