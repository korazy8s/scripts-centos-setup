#!/bin/sh
yum -y install epel-release
yum -y update
yum -y install redis

sysctl vm.overcommit_memory=1
# /etc/sysctl.conf
# sysctl vm.overcommit_memory=1

cat > /etc/redis.conf <<EOL
# Redis configuration file example.
# Redis Security https://redis.io/topics/security
# Note that in order to read the configuration file, Redis must be
# started with the file path as first argument:
# ./redis-server /path/to/redis.conf
# include /path/to/local.conf
# include /path/to/other.conf
# bind 127.0.0.1
protected-mode yes
port 6379
tcp-backlog 511
# unixsocket /tmp/redis.sock
# unixsocketperm 700
timeout 0
tcp-keepalive 300
daemonize no
supervised no
pidfile /var/run/redis_6379.pid
loglevel notice
logfile /var/log/redis/redis.log
# syslog-enabled no
# syslog-ident redis
# syslog-facility local0
databases 16
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /var/lib/redis
# slaveof <masterip> <masterport>
# masterauth <master-password>
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
# repl-ping-slave-period 10
# repl-timeout 60
repl-disable-tcp-nodelay no
# repl-backlog-size 1mb
# repl-backlog-ttl 3600
slave-priority 100
# min-slaves-to-write 3
# min-slaves-max-lag 10
# min-slaves-max-lag is set to 10.
# slave-announce-ip 5.5.5.5
# slave-announce-port 1234
requirepass Aut0.soft
# rename-command CONFIG b840fc02d524045429941cc15f59e41cb7be6c52
# maxclients 10000
# maxmemory <bytes>
# maxmemory-policy noeviction
# maxmemory-samples 5
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
# appendfsync no
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
lua-time-limit 5000
# cluster-enabled yes
# cluster-config-file nodes-6379.conf
# cluster-node-timeout 15000
# cluster-slave-validity-factor 10
# cluster-migration-barrier 1
# cluster-require-full-coverage yes
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes
EOL

systemctl start redis
systemctl enable redis
redis-cli ping

firewall-cmd --add-port=6379/tcp --permanent
systemctl restart firewalld
