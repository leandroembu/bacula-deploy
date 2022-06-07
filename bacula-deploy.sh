#!/bin/env bash
bacula_version="11.0.6"
job_email="leandroramos@disroot.org"
host="bacula.example.com"
pg_version="13"
db_name="bacula"
db_user="bacula"
db_password="bacula"
db_port="5432"

export DEBIAN_FRONTEND=noninteractive

# Dependencies
apt-get install -y build-essential libreadline6-dev zlib1g-dev liblzo2-dev mt-st mtx postfix libacl1-dev libssl-dev postgresql-server-dev-${pg_version} postgresql-${pg_version}
# Source code download
wget -qO- https://ufpr.dl.sourceforge.net/project/bacula/bacula/${bacula_version}/bacula-${bacula_version}.tar.gz | tar -xzvf - -C /usr/src
#==================================================================

# Compilar para uso com PostgreSQL
cd /usr/src/bacula*

./configure \
 --enable-smartalloc \
 --with-postgresql \
 --with-db-user=${db_user} \
 --with-db-password=${db_password} \
 --with-db-port=${db_port} \
 --with-openssl \
 --with-readline=/usr/include/readline \
 --sysconfdir=/etc/bacula \
 --bindir=/usr/bin \
 --sbindir=/usr/sbin \
 --with-scriptdir=/etc/bacula/scripts \
 --with-plugindir=/etc/bacula/plugins \
 --with-pid-dir=/var/run \
 --with-subsys-dir=/etc/bacula/working \
 --with-working-dir=/etc/bacula/working \
 --with-bsrdir=/etc/bacula/bootstrap \
 --with-s3=/usr/local \
 --with-basename="${db_name}" \
 --with-hostname=${host} \
 --with-systemd \
 --disable-conio \
 --disable-nls \
 --with-logdir=/var/log/bacula \
 --with-dump-email=${job_email} \
 --with-job-email=${job_email}

make -j8 && make install && make install-autostart
##################################################################

#=================================================================
# Create PostgreSQL database and grant privileges
sed -i 's/peer/trust/g' /etc/postgresql/${pg_version}/main/pg_hba.conf
sed -i 's/ident/trust/g' /etc/postgresql/${pg_version}/main/pg_hba.conf
sed -i 's/md5/trust/g' /etc/postgresql/${pg_version}/main/pg_hba.conf
service postgresql restart
cp /etc/bacula/scripts/* /tmp
chmod o+rx /tmp/*
sudo -u postgres /tmp/create_postgresql_database
sudo -u postgres /tmp/make_postgresql_tables
sudo -u postgres /tmp/grant_postgresql_privileges
##################################################################

service bacula-fd start && service bacula-sd start && service bacula-dir start

echo "Try to access Bacula's Console from the shell with command: bconsole"
