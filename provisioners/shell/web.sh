service --status-all|grep -q httpd
if [ $? -ne 0 ];then
  # install httpd
  yum -y install httpd
  # modify runlevels for httpd service
  # chkconfig --list httpd
  # httpd          	0:off	1:off	2:off	3:off	4:off	5:off	6:off
  chkconfig --levels 235 httpd on
fi
