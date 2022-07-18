#!/bin/bash

# Load os-release variables
. /etc/os-release

os=$ID
os_version=$VERSION_CODENAME

# Add repository key
wget -qO - https://www.bacula.org/downloads/baculum/baculum.pub | apt-key add -

# Add Baculum repository
echo "
  deb [ arch=amd64 ] https://www.bacula.org/downloads/baculum/stable-11/${os} ${os_version} main
  deb-src https://www.bacula.org/downloads/baculum/stable-11/${os} ${os_version} main
" > /etc/apt/sources.list.d/baculum.list

# Install dependencies
apt-get update && apt-get install -y php-bcmath php-mbstring baculum-api baculum-api-apache2 baculum-common baculum-web baculum-web-apache2

# Adjust www-data sudo permissions
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

# Configure apache
a2enmod rewrite
a2ensite baculum-web baculum-api
service apache2 restart

# Print Baculum URL
server_ip=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')

echo "======= Bacula Director: ======="
echo "Try to access Bacula's Console from the shell with command: bconsole"
echo "======= Baculum API and Web: ======="
echo "Access and configure API at http://$server_ip:9096/ (admin-admin) then configure Baculum http://$server_ip:9095/"
