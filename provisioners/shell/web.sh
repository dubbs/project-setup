

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
