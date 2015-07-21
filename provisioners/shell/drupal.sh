export PATH=/usr/local/bin:$PATH

# DRUPAL INSTALL
if [ ! -f /var/www/example.com/sites/default/settings.php ];then
  echo drupal
  rm -rf /var/www/example.com
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
  # security_review for review of settings
  drush -y en views devel advanced_help syslog pathauto metatag transliteration admin_menu security_review
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
  # cron
  drush cron
  # restart
  service httpd restart
fi
