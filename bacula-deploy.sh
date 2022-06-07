#!/bin/env bash
bacula_version="11.0.6"
job_email="leandroramos@disroot.org"
host="bacula.example.com"
number_cpus=2

export DEBIAN_FRONTEND=noninteractive

# Dependencies
apt-get install -y build-essential libreadline6-dev zlib1g-dev liblzo2-dev mt-st mtx postfix libacl1-dev libssl-dev postgresql-server-dev-13 postgresql-13
# Source code download
wget -qO- https://ufpr.dl.sourceforge.net/project/bacula/bacula/${bacula_version}/bacula-${bacula_version}.tar.gz | tar -xzvf - -C /usr/src
#==================================================================
# Compilar para uso com PostgreSQL
cd /usr/src/bacula*

./configure --with-readline=/usr/include/readline --disable-conio --bindir=/usr/bin --sbindir=/usr/sbin --with-scriptdir=/etc/bacula/scripts --with-working-dir=/var/lib/bacula --with-logdir=/var/log --enable-smartalloc --with-postgresql --with-archivedir=/mnt/backup --with-job-email=${job_email} --with-hostname=${host}

make -j${number_cpus} && make install && make install-autostart
##################################################################

#=================================================================
# Create PostgreSQL database and grant privileges
postgresql-setup initdb
sed -i 's/peer/trust/g' /var/lib/pgsql/data/pg_hba.conf
sed -i 's/ident/trust/g' /var/lib/pgsql/data/pg_hba.conf
service postgresql start
chkconfig postgresql on
cp /etc/bacula/scripts/* /tmp
chmod o+rx /tmp/*
sudo -u postgres /tmp/create_postgresql_database
sudo -u postgres /tmp/make_postgresql_tables
sudo -u postgres /tmp/grant_postgresql_privileges
##################################################################

service bacula-fd start && service bacula-sd start && service bacula-dir start

echo "Try to access Bacula's Console from the shell with command: bconsole"
