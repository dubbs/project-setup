
#export PATH=/usr/local/bin:$PATH

## turn off fastestmirror
#sed -i 's/^enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf


## COMPOSER
#if [ ! -f /usr/local/bin/composer ];then
  #echo composer
  #curl -sS https://getcomposer.org/installer | php
  #mv composer.phar /usr/local/bin/composer
#fi

## DRUSH
## test if file exists and is a symlink
#if [ ! -L /usr/local/bin/drush ];then
  #echo drush
  #composer global require drush/drush:7.*
  #ln -fs /root/.composer/vendor/bin/drush /usr/local/bin/drush
#fi


## DRUPAL INSTALL
#if [ ! -f /var/www/example.com/sites/default/settings.php ];then
  #echo drupal
  #rm -rf /var/www/example.com
  #cd /var/www
  ## download/install drupal7
  #drush dl drupal-7.x --drupal-project-rename=example.com
  #cd example.com
  #drush -y site-install standard --db-url='mysql://admin:password@localhost/example_com' --account-name=admin --account-pass=password --site-name=Example
  ## dblog replaced by syslog
  ## toolbar replaced by admin_menu
  #drush -y dis dblog toolbar
  ## syslog for logging to file
  ## pathauto for pretty urls
  ## metatag for automatic metatags
  ## transliteration for cleaning up filenames during upload
  ## admin_menu for easy admin nav
  ## security_review for review of settings
  #drush -y en views devel advanced_help syslog pathauto metatag transliteration admin_menu security_review
  ## view_ui for ui based views admin
  ## devel_generate for content
  #drush -y en views_ui devel_generate
  ## set appropriate permissions for files directory
  #chmod -R 0700 /var/www/example.com/sites/default/files
  ## set appropriate permissions for site
  #chown -R apache:apache /var/www/example.com
  ## syslog 
  #drush vset syslog_identity example_com
  #echo 'local0.* /var/log/example_com.log' >> /etc/rsyslog.conf
  #service rsyslog restart
  ## pathauto
  #drush vset pathauto_node_article_pattern 'article/[node:title]'
  ## region
  #drush vset site_default_country 'CA'
  #drush vset date_default_timezone 'America/Regina'
  ## security_review recommendations
  #echo "\$base_url = 'http://example.com';" >> /var/www/example.com/sites/default/settings.php
  #drush vset error_level 0
  #. /vagrant/config/drupal/fix-permissions.sh --drupal_path=/var/www/example.com --drupal_user=root --httpd_group=apache
  ## cron
  #drush cron
  ## restart
  #service httpd restart
#fi

### DRUPAL THEME BOOTSTRAP
#if [ ! -d /var/www/example.com/sites/all/themes/bootstrap ];then
  #drush -y en jquery_update bootstrap
  #drush vset theme_default bootstrap
#fi

### DRUPAL THEME OMEGA
#if [ ! -d /var/www/example.com/sites/all/themes/omega ];then
  #drush -y en jquery_update omega
  #drush omega-subtheme --enable --set-default omegasub
  #cat /vagrant/config/drupal/omega-settings.info >> /var/www/example.com/sites/all/themes/omegasub/omegasub.info
#fi

### VARNISH
#rpm -qa|grep varnish > /dev/null
#if [ $? -ne 0 ];then
  #echo varnish
  ## install varnish
  #rpm --nosignature -i https://repo.varnish-cache.org/redhat/varnish-4.0.el6.rpm
  #yum -y install varnish
  #chkconfig --levels 345 varnish on
  ## update ports so forwards to apache
  #sed -i 's/80/8080/' /etc/httpd/conf/httpd.conf
  #sed -i 's/^VARNISH_LISTEN_PORT=6081/VARNISH_LISTEN_PORT=80/' /etc/sysconfig/varnish
  ## update config, \cp will run original cp command without alias, which is cp -i
  #\cp /vagrant/config/varnish/default.vcl /etc/varnish/
  ## install drupal module and set config
  #cd /var/www/example.com
  #drush -y dl varnish-7.x-1.x-dev
  #drush en -y varnish
  ## this prompts for input, 1 = cache
  #echo 1 | drush vset cache 1
  #drush vset block_cache 1
  #drush vset page_cache_maximum_age 900
  #drush vset cache_lifetime 0
  #drush vset varnish_version 4
  #cat /etc/varnish/secret | xargs drush vset varnish_control_key
  ## restart
  #service httpd restart
  #service varnish restart
#fi
