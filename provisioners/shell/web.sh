
export PATH=/usr/local/bin:$PATH

# HTTPD
rpm -qa|grep httpd > /dev/null
# $? return code from last command
if [ $? -ne 0 ];then
  echo httpd
  # install httpd
  yum -y install httpd
  # set runlevels for httpd service
  #   chkconfig --list httpd
  #   httpd 0:off 1:off 2:off 3:off 4:off 5:off 6:off
  chkconfig --levels 345 httpd on
  # enable named virtual hosts
  sed -i.orig 's/^#NameVirtualHost/NameVirtualHost/' /etc/httpd/conf/httpd.conf
  # set server name
  sed -i.orig2 's/^#ServerName www.example.com:80/ServerName 192.168.33.10/' /etc/httpd/conf/httpd.conf
  # add virtual host entry to conf
  cat /vagrant/config/httpd/vhosts.conf >> /etc/httpd/conf/httpd.conf
  # symlink public
  # this has been moved to vagrantfile for now
  ln -s /vagrant/public_html /var/www/example.com
  # start httpd
  service httpd start
fi

# PHP
rpm -qa|grep php > /dev/null
if [ $? -ne 0 ];then
  echo php
  # add webtatic repository
  rpm -Uvh http://mirror.webtatic.com/yum/el6/latest.rpm
  # install php extensions
  # gd for drush
  # apcu for drupal upload progress
  # mbstring for improved unicode support in drupal
  # yum search php56
  yum -y install php56w php56w-mysql php56w-gd php56w-mbstring php56w-pecl-zendopcache php56w-pecl-xdebug php56w-pecl-apcu
  # enable apc for file upload
  sed -i 's/^apc.rfc1867=0/apc.rfc1867=1/' /etc/php.d/apcu.ini
  # @see /etc/httpd/conf.d/php.conf
  service httpd restart
fi

# COMPOSER
if [ ! -f /usr/local/bin/composer ];then
  echo composer
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
fi

# DRUSH
# /usr/local/bin/composer global show -i|grep drush > /dev/null
# test if symlink and file exist
if [ ! -L /usr/local/bin/drush ];then
  echo drush
  /usr/local/bin/composer global require drush/drush:7.*
  ln -fs /root/.composer/vendor/bin/drush /usr/local/bin/drush
fi

# MARIADB
rpm -qa|grep MariaDB > /dev/null
if [ $? -ne 0 ];then
  echo maria
  ln -s /vagrant/config/yum/MariaDB.repo /etc/yum.repos.d/MariaDB.repo
  yum -y install MariaDB-server MariaDB-client
  chkconfig --levels 345 mysql on
  service mysql start
fi

# DB
if [ ! -d /var/lib/mysql/example_com ];then
  echo dbusers
  mysql -uroot -e "CREATE DATABASE example_com;"
  mysql -uroot -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';"
  mysql -uroot -e "GRANT ALL PRIVILEGES ON example_com.* TO admin@'%' IDENTIFIED BY 'password';"
  mysql -uroot -e "GRANT ALL PRIVILEGES ON example_com.* TO admin@localhost IDENTIFIED BY 'password';"
  mysql -uroot -e "FLUSH PRIVILEGES;"
fi

# DRUPAL INSTALL
if [ ! -f /var/www/example.com/sites/default/settings.php ];then
  echo drupal
  rm -f /var/www/example.com
  cd /var/www
  # download/install drupal7
  drush dl drupal-7.x --drupal-project-rename=example.com
  cd example.com
  drush -y site-install standard --db-url='mysql://admin:password@localhost/example_com' --account-name=admin --account-pass=password --site-name=Example
  # enable base modules
  drush -y en views devel advanced_help
  # enable base module extensions
  drush -y en views_ui devel_generate
  # set appropriate permissions for files directory
  chmod -R 0700 /var/www/example.com/sites/default/files
  # set appropriate permissions for site
  chown -R apache:apache /var/www/example.com
fi

## VARNISH
rpm -qa|grep varnish > /dev/null
if [ $? -ne 0 ];then
  echo varnish
  rpm --nosignature -i https://repo.varnish-cache.org/redhat/varnish-4.0.el6.rpm
  yum -y install varnish
  chkconfig --levels 345 varnish on
  sed -i 's/^Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
  sed -i 's/^VARNISH_LISTEN_PORT=6081/VARNISH_LISTEN_PORT=80/' /etc/sysconfig/varnish
  service varnish restart
  service httpd restart
  # @todo copy config/varnish/default.vcl
  # @todo drush en -y varnish
  # @todo copy /etc/varnish/secret to varnish config page
fi
