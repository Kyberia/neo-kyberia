#!/usr/bin/zsh

set -x

/usr/bin/mysqld_pre_systemd
/usr/sbin/mysqld --pid-file=/var/run/mysqld/mysqld.pid
