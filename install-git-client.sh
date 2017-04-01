#!/bin/sh
sudo yum -y install git
git --version
git clone https://github.com/korazy8s/scripts-centos-setup .
chmod +x *.sh
