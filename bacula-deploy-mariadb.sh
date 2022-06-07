#!/bin/env bash
bacula_version="11.0.6"
job_email="leandroramos@disroot.org"
host="bacula.example.com"
number_cpus=2

export DEBIAN_FRONTEND=noninteractive

# Dependencies
apt-get install build-essential libreadline6-dev zlib1g-dev liblzo2-dev mt-st mtx postfix libacl1-dev libssl-dev libmysql++-dev default-mysql-server
# Source code download
wget -qO- https://ufpr.dl.sourceforge.net/project/bacula/bacula/${bacula_version}/bacula-${bacula_version}.tar.gz | tar -xzvf - -C /usr/src
#==================================================================
# Compilar para uso com MariaDB
cd /usr/src/bacula*

./configure --with-readline=/usr/include/readline --disable-conio --bindir=/usr/bin --sbindir=/usr/sbin --with-scriptdir=/etc/bacula/scripts --with-working-dir=/var/lib/bacula --with-logdir=/var/log --enable-smartalloc --with-mysql --with-archivedir=/mnt/backup --with-job-email=${job_email} --with-hostname=${host}

make -j${number_cpus} && make install && make install-autostart
##################################################################

#=================================================================
# Create MariaDB database and grant privileges
chmod o+rx /etc/bacula/scripts/*
/etc/bacula/scripts/create_mysql_database -u root -p && \
/etc/bacula/scripts/make_mysql_tables -u root -p && \
/etc/bacula/scripts/grant_mysql_privileges -u root -p
##################################################################

service bacula-fd start && service bacula-sd start && service bacula-dir start

echo "Try to access Bacula's Console from the shell with command: bconsole"
