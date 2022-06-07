#!/usr/bin/env bash                                                                                                                                                                            
debian_version="bullseye"      

export DEBIAN_FRONTEND=noninteractive
  
apt-get update && apt-get install -y gnupg bacula-server bacula-director-mysql bacula-sd bacula-fd bacula-console

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

usermod -aG bacula www-data 
chown -R www-data:bacula /etc/bacula
chmod -R g+rwx /etc/bacula
a2enmod rewrite
a2ensite baculum-web baculum-api
service apache2 restart
