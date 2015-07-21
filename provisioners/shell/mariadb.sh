# MARIADB
rpm -qa|grep MariaDB > /dev/null
# $? return code from last command
if [ $? -ne 0 ];then
  echo mariadb
  #ln -fs /vagrant/config/yum/MariaDB.repo /etc/yum.repos.d/MariaDB.repo
  yum -y install MariaDB-server MariaDB-client
  chkconfig --levels 345 mysql on
  service mysql start
  service httpd restart
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
