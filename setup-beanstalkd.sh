
#!/bin/sh
HOSTNAME=id-sqs1

# install latest updates
yum -y update

# setup automatic updates manager
yum -y install yum-cron
systemctl start yum-cron
sed -ie 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf

# install vmware tools
yum -y install open-vm-tools

# install dependencies
yum -y install group "Development Tools"
yum -y install git
yum -y install firewalld

# get beanstalkd install
git clone git://github.com/kr/beanstalkd.git
cd beanstalkd
make
cp beanstalkd /usr/bin/beanstalkd
mkdir /var/lib/beanstalkd

# write config file
cat >/etc/systemd/system/beanstalkd.service <<EOL
[Unit]
Description=Beanstalkd is a simple, fast work queue

[Service]
User=root
ExecStart=/usr/bin/beanstalkd -b /var/lib/beanstalkd

[Install]
WantedBy=multi-user.target
EOL

# set machine info
hostnamectl set-hostname ${HOSTNAME}

# enable firewall rules
systemctl restart firewalld
firewall-cmd --zone=public --add-port=ssh/tcp --permanent
firewall-cmd --zone=public --add-port=11300/tcp --permanent
systemctl restart firewalld

# enable and start service
systemctl enable beanstalkd
systemctl start beanstalkd

# show processes
ps ax | grep beanstalkd

# show ports
netstat -tulpn

# reboot to be sure
reboot
