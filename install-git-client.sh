#!/bin/sh
sudo yum -y install git
git --version
git clone https://github.com/korazy8s/scripts-centos-setup .
git fetch origin && git reset --hard origin/master && chmod +x *.sh
chmod +x *.sh
