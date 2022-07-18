#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Dependencies
apt-get update && apt-get install -y curl wget build-essential zlib1g-dev liblzo2-dev libacl1-dev libssl-dev

bacula_version=$(
	curl -qsL "https://sourceforge.net/projects/bacula/best_release.json" \
	| sed "s/, /,\n/g" \
	| sed -rn "/release/,/\}/{ /filename/{ 0,//s/([^0-9]*)([0-9\.]+)([^0-9]*.*)/\2/ p }}"
)

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
bacula status
