# PHP
rpm -qa|grep php > /dev/null
# $? return code from last command
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
  # add test file
  echo '<?php echo phpinfo(); ?>' > /var/www/example.com/index.php
  # @see /etc/httpd/conf.d/php.conf
  service httpd restart
fi
