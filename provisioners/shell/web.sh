# HTTPD
rpm -qa|grep httpd > /dev/null
# $? return code from last command
if [ $? -ne 0 ];then
  # install httpd
  yum -y install httpd
  # set runlevels for httpd service
  #   chkconfig --list httpd
  #   httpd 0:off 1:off 2:off 3:off 4:off 5:off 6:off
  chkconfig --levels 235 httpd on
  # enable named virtual hosts
  sed -i.orig 's/^#NameVirtualHost/NameVirtualHost/' /etc/httpd/conf/httpd.conf
  # add virtual host entry to conf
  cat /vagrant/config/httpd/vhosts.conf >> /etc/httpd/conf/httpd.conf
  # symlink public
  ln -s /vagrant/public_html /var/www/example.com
  # start httpd
  service httpd start
fi

# PHP
rpm -qa|grep php > /dev/null
if [ $? -ne 0 ];then
  yum -y install php
  service httpd restart
fi
