
export PATH=/usr/local/bin:$PATH

# HTTPD
rpm -qa|grep httpd > /dev/null
# $? return code from last command
if [ $? -ne 0 ];then
  # install httpd
  yum -y install httpd
  # set runlevels for httpd service
  #   chkconfig --list httpd
  #   httpd 0:off 1:off 2:off 3:off 4:off 5:off 6:off
  chkconfig --levels 2345 httpd on
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
  # add webtatic repository
  rpm -Uvh http://mirror.webtatic.com/yum/el6/latest.rpm
  # install php extensions, gd for drupal
  yum -y install php56w php56w-mysql php56w-gd php56w-pecl-zendopcache php56w-pecl-xdebug
  # @see /etc/httpd/conf.d/php.conf
  service httpd restart
fi

# COMPOSER
if [ ! -f /usr/local/bin/composer ];then
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
fi

# DRUSH
# /usr/local/bin/composer global show -i|grep drush > /dev/null
# test if symlink and file exist
if [ ! -L /usr/local/bin/drush ];then
  /usr/local/bin/composer global require drush/drush:7.*
  ln -fs /root/.composer/vendor/bin/drush /usr/local/bin/drush
fi

# MARIADB
rpm -qa|grep MariaDB > /dev/null
if [ $? -ne 0 ];then
  ln -s /vagrant/config/yum/MariaDB.repo /etc/yum.repos.d/MariaDB.repo
  yum -y install MariaDB-server MariaDB-client
  chkconfig --levels 2345 mysql on
  service mysql start
fi

# DB
if [ ! -d /var/lib/mysql/example_com ];then
  mysql -uroot -e "CREATE DATABASE example_com;"
  mysql -uroot -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';"
  mysql -uroot -e "GRANT ALL PRIVILEGES ON example_com.* TO admin@'%' IDENTIFIED BY 'password';"
  mysql -uroot -e "GRANT ALL PRIVILEGES ON example_com.* TO admin@localhost IDENTIFIED BY 'password';"
  mysql -uroot -e "FLUSH PRIVILEGES;"
fi

# DRUPAL
if [ ! -f /var/www/example.com/sites/default/settings.php ];then
  rm -f /var/www/example.com
  cd /var/www
  drush dl drupal-7.x --drupal-project-rename=example.com
  cd example.com
  drush -y site-install standard --db-url='mysql://admin:password@localhost/example_com' --account-name=admin --account-pass=password --site-name=Example
fi

