#!/bin/sh
yum -y install epel-release
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
yum -y update
yum -y install munin munin-node
systemctl enable munin-node
systemctl start munin-node
htpasswd /etc/munin/munin-htpasswd admin
