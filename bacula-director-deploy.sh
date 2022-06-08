#!/bin/env bash
debian_version="bullseye"
bacula_version="11.0.6"
job_email="leandroramos@disroot.org"
host="bacula.example.com"
pg_version="12"
db_name="bacula"
db_user="bacula"
db_password="bacula"
db_port="5432"

export DEBIAN_FRONTEND=noninteractive

# Dependencies
apt-get update && apt-get install -y build-essential libreadline6-dev zlib1g-dev liblzo2-dev mt-st mtx postfix libacl1-dev libssl-dev postgresql-server-dev-${pg_version} postgresql-${pg_version}
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
sed -i 's/peer/trust/g; s/ident/trust/g; s/md5/trust/g' /etc/postgresql/${pg_version}/main/pg_hba.conf
service postgresql restart
cp /etc/bacula/scripts/* /tmp
chmod o+rx /tmp/*
sudo -u postgres /tmp/create_postgresql_database
sudo -u postgres /tmp/make_postgresql_tables
sudo -u postgres /tmp/grant_postgresql_privileges
##################################################################

service bacula-fd start && service bacula-sd start && service bacula-dir start

# Install and configure Baculum
wget -qO - https://www.bacula.org/downloads/baculum/baculum.pub | apt-key add -

echo "
deb [ arch=amd64 ] https://www.bacula.org/downloads/baculum/stable-11/debian ${debian_version} main
deb-src https://www.bacula.org/downloads/baculum/stable-11/debian ${debian_version} main
" > /etc/apt/sources.list.d/baculum.list

apt-get update && apt-get install -y php-bcmath php-mbstring baculum-api baculum-api-apache2 baculum-common baculum-web baculum-web-apache2

echo "Defaults:apache "'!'"requiretty
www-data ALL=NOPASSWD: /usr/sbin/bconsole
www-data ALL=NOPASSWD: /usr/sbin/bdirjson
www-data ALL=NOPASSWD: /usr/sbin/bsdjson
www-data ALL=NOPASSWD: /usr/sbin/bfdjson
www-data ALL=NOPASSWD: /usr/sbin/bbconsjson
www-data ALL=(root) NOPASSWD: /usr/bin/systemctl start bacula-dir
www-data ALL=(root) NOPASSWD: /usr/bin/systemctl stop bacula-dir
www-data ALL=(root) NOPASSWD: /usr/bin/systemctl restart bacula-dir
www-data ALL=(root) NOPASSWD: /usr/bin/systemctl start bacula-sd
www-data ALL=(root) NOPASSWD: /usr/bin/systemctl stop bacula-sd
www-data ALL=(root) NOPASSWD: /usr/bin/systemctl restart bacula-sd
www-data ALL=(root) NOPASSWD: /usr/bin/systemctl start bacula-fd
www-data ALL=(root) NOPASSWD: /usr/bin/systemctl stop bacula-fd
www-data ALL=(root) NOPASSWD: /usr/bin/systemctl restart bacula-fd
www-data ALL=(root) NOPASSWD: /etc/bacula/scripts/mtx-changer
" > /etc/sudoers.d/baculum

groupadd bacula
usermod -aG bacula www-data
chown -R www-data:bacula /etc/bacula/working /etc/bacula
chmod -R g+rwx /etc/bacula/working /etc/bacula
a2enmod rewrite
a2ensite baculum-web baculum-api
service apache2 restart

server_ip=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')

echo "======= Bacula Director: ======="
echo "Try to access Bacula's Console from the shell with command: bconsole"
echo "======= Baculum API and Web: ======="
echo "Access and configure API at http://$server_ip:9096/ (admin-admin) then configure Baculum http://$server_ip:9095/"
