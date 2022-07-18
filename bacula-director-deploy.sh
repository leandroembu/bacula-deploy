#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Dependencies
apt-get update && apt-get install -y curl wget build-essential libreadline6-dev zlib1g-dev liblzo2-dev mt-st mtx postfix libacl1-dev libssl-dev postgresql-server-dev-all postgresql

bacula_version=$(
	curl -qsL "https://sourceforge.net/projects/bacula/best_release.json" \
	| sed "s/, /,\n/g" \
	| sed -rn "/release/,/\}/{ /filename/{ 0,//s/([^0-9]*)([0-9\.]+)([^0-9]*.*)/\2/ p }}"
)

job_email="leandroramos@disroot.org"
host="bacula.example.com"
db_name="bacula"
db_user="bacula"
db_password="bacula"
db_port="5432"

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
# TODO: avoid using trust in pg_hba.conf

pg_hba_path=$(su - postgres -c \
        "psql -t -P format=unaligned -c 'SHOW config_file';" \
        | sed 's/postgresql.conf/pg_hba.conf/g'
)

sed -i 's/peer/trust/g; s/ident/trust/g; s/md5/trust/g' $pg_hba_path
service postgresql restart
cp /etc/bacula/scripts/* /tmp
chmod o+rx /tmp/*
sudo -u postgres /tmp/create_postgresql_database
sudo -u postgres /tmp/make_postgresql_tables
sudo -u postgres /tmp/grant_postgresql_privileges
##################################################################

service bacula-fd start && service bacula-sd start && service bacula-dir start

bacula status
