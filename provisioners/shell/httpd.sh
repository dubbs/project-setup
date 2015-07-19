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
  # add test file
  mkdir -p /var/www/example.com
  echo 'HTML' > /var/www/example.com/index.html
  # start httpd
  service httpd start
fi
