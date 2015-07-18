
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
  # dblog replaced by syslog
  # toolbar replaced by admin_menu
  drush -y dis dblog toolbar
  # syslog for logging to file
  # pathauto for pretty urls
  # metatag for automatic metatags
  # transliteration for cleaning up filenames during upload
  # admin_menu for easy admin nav
  drush -y en views devel advanced_help syslog pathauto metatag transliteration admin_menu
  # view_ui for ui based views admin
  # devel_generate for content
  drush -y en views_ui devel_generate
  # set appropriate permissions for files directory
  chmod -R 0700 /var/www/example.com/sites/default/files
  # set appropriate permissions for site
  chown -R apache:apache /var/www/example.com
  # syslog 
  drush vset syslog_identity example_com
  echo 'local0.* /var/log/example_com.log' >> /etc/rsyslog.conf
  service rsyslog restart
  # pathauto
  drush vset pathauto_node_article_pattern 'article/[node:title]'
  # region
  drush vset site_default_country 'CA'
  drush vset date_default_timezone 'America/Regina'
  # security_review recommendations
  echo "\$base_url = 'http://example.com';" >> /var/www/example.com/sites/default/settings.php
  drush vset error_level 0
  . /vagrant/config/drupal/fix-permissions.sh --drupal_path=/var/www/example.com --drupal_user=root --httpd_group=apache
fi

## DRUPAL THEME BOOTSTRAP
if [ ! -d /var/www/example.com/sites/all/themes/bootstrap ];then
  drush -y en jquery_update bootstrap
  drush vset theme_default bootstrap
fi

## DRUPAL THEME OMEGA
if [ ! -d /var/www/example.com/sites/all/themes/omega ];then
  drush -y en omega
  drush omega-subtheme --enable --set-default omegasub
  cat /vagrant/config/drupal/omega-settings.info >> /var/www/example.com/sites/all/themes/omegasub/omegasub.info
fi

## VARNISH
rpm -qa|grep varnish > /dev/null
if [ $? -ne 0 ];then
  echo varnish
  # install varnish
  rpm --nosignature -i https://repo.varnish-cache.org/redhat/varnish-4.0.el6.rpm
  yum -y install varnish
  chkconfig --levels 345 varnish on
  # update ports so forwards to apache
  sed -i 's/80/8080/' /etc/httpd/conf/httpd.conf
  sed -i 's/^VARNISH_LISTEN_PORT=6081/VARNISH_LISTEN_PORT=80/' /etc/sysconfig/varnish
  # update config, \cp will run original cp command without alias, which is cp -i
  \cp /vagrant/config/varnish/default.vcl /etc/varnish/
  # install drupal module and set config
  cd /var/www/example.com
  drush -y dl varnish-7.x-1.x-dev
  drush en -y varnish
  # this prompts for input, 1 = cache
  echo 1 | drush vset cache 1
  drush vset block_cache 1
  drush vset page_cache_maximum_age 900
  drush vset cache_lifetime 0
  drush vset varnish_version 4
  cat /etc/varnish/secret | xargs drush vset varnish_control_key
  # restart
  service httpd restart
  service varnish restart
fi
