#!/bin/sh
yum -y install epel-release
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
yum -y update
yum -y install munin munin-node
sudo ln -s /usr/share/munin/plugins/apache_processes /etc/munin/plugins/apache_processes
sudo ln -s /usr/share/munin/plugins/apache_accesses /etc/munin/plugins/apache_accesses
sudo ln -s /usr/share/munin/plugins/apache_volume /etc/munin/plugins/apache_volume
systemctl enable munin-node
systemctl start munin-node

cat > /etc/munin/munin.conf <<EOL
#dbdir  /var/lib/munin
#htmldir /var/www/html/munin
#logdir /var/log/munin
#rundir  /var/run/munin
#tmpldir        /etc/munin/templates
#staticdir /etc/munin/static
cgitmpdir /var/tmp
# (Exactly one) directory to include all files from.
includedir /etc/munin/conf.d
#graph_period second
graph_strategy cron
#munin_cgi_graph_jobs 6
cgiurl_graph /munin-cgi/munin-cgi-graph
#max_size_x 4000
#max_size_y 4000
html_strategy cron
#max_processes 16
#rrdcached_socket /var/run/rrdcached.sock
#contact.someuser.command mail -s "Munin notification" somejuser@fnord.comm
#contact.anotheruser.command mail -s "Munin notification" anotheruser@blibb.comm
#contact.nagios.command /usr/bin/send_nsca nagios.host.comm -c /etc/nsca.conf
[${HOSTNAME}]
    address 127.0.0.1
    use_node_name yes
EOL

cat > /etc/httpd/conf.d/munin.conf <<EOL
<IfModule mod_status.c>
  ExtendedStatus On
  <Location /server-status>
    SetHandler server-status
    Order deny,allow
    Deny from all
    Allow from localhost ip6-localhost
  </Location>
</IfModule>
EOL

htpasswd /etc/munin/munin-htpasswd admin
