#!/bin/env bash

bacula_version="11.0.6"

export DEBIAN_FRONTEND=noninteractive

# Dependencies
apt-get install -y build-essential zlib1g-dev liblzo2-dev libacl1-dev libssl-dev
# Source code download
wget -qO- https://ufpr.dl.sourceforge.net/project/bacula/bacula/${bacula_version}/bacula-${bacula_version}.tar.gz | tar -xzvf - -C /usr/src
#==================================================================

# Compiling
cd /usr/src/bacula*

./configure \
 --enable-client-only \
 --enable-build-dird=no \
 --enable-build-stored=no \
 --bindir=/usr/bin \
 --sbindir=/usr/sbin \
 --with-scriptdir=/etc/bacula/scripts \
 --with-working-dir=/etc/bacula/working \
 --with-logdir=/var/log \
 --with-systemd \
 --enable-smartalloc

make -j8 && make install && make install-autostart-fd
##################################################################

service bacula-fd start
