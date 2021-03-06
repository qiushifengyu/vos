#centos 6.5 install vos4.0

yum remove -y perl-DBI  jdk  mysql-libs
yum install -y wget ntpdate glibc.i686 zip unzip crontabs sudo
sed -i '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config
echo  "127.0.0.1 www.linknat.com" >> /etc/hosts
wget -qO /etc/sysctl.conf https://oss.1nth.com/environment/aliyun-sysctl.conf --no-check-certificate
ntpdate time.sicdt.com && hwclock -w

wget https://1nth.oss-cn-beijing.aliyuncs.com/kernel-2.6.32-358.el6.x86_64.rpm
rpm -ivh kernel-2.6.32-358.el6.x86_64.rpm --oldpackage

awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg
#查看系统启动内核顺序
grub2-set-default 0
#内核启动顺序是从0开始 从上到下

wget http://oss.1nth.com/vospag/vos3000-2.1.4.0.tar.gz
tar -zxvf vos3000-2.1.4.0.tar.gz
cd vos4.0/
setenforce 0
sh create_user_kunshi.sh
sh create_user_kunshiweb.sh
yum localinstall -y perl-DBI-1.40-5.i386.rpm --nogpgcheck
rpm -qa|grep -i mysql
rpm -ivh MySQL-server-community-5.0.96-1.rhel5.x86_64.rpm
rpm -ivh MySQL-client-community-5.0.96-1.rhel5.x86_64.rpm
tee /etc/my.cnf <<-'EOF'
[client]
port=3306
default-character-set=utf8
[mysqld]
default-character-set=utf8
max_connections=160
interactive_timeout=310000
wait_timeout=31000
query_cache_size=48M
table_cache=320
tmp_table_size=52M
thread_cache_size=8
sort_buffer_size=256K
innodb_thread_concurrency=8
myisam-recover=FORCE
max_allowed_packet=32M
innodb_file_per_table=1
EOF

service mysql restart
rpm -ivh jdk-6u45-linux-amd64.rpm
tar zxvf apache-tomcat-7.0.23.tar.gz
mv apache-tomcat-7.0.23 /home/kunshiweb/base/apache-tomcat
chmod 777 jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin
./jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin

cp -r /root/jrockit-jdk1.6.0_45-R28.2.7-4.1.0 /home/kunshi/base/jdk_default
cp -r /root/jrockit-jdk1.6.0_45-R28.2.7-4.1.0 /home/kunshiweb/base/jdk_default
rpm -ivh vos3000-2.1.4-0.i586.rpm

rpm -ivh emp-2.1.4-0.noarch.rpm
rpm -ivh callservice-2.1.4-0.i586.rpm
rpm -ivh mgc-2.1.4-0.i586.rpm

rpm -ivh vos3000-web*.rpm

rpm -ivh mbx3000-2.1.4-0.i586.rpm
rpm -ivh ivr_dial-2.1.4-0.i586.rpm
rpm -ivh callcenter-2.1.4-0.i586.rpm
cd phoneservice/
cp -r phoneservice /home/kunshi/
chmod 777 /home/kunshi/phoneservice/bin/phoneservice
cp -r phoneserviced /etc/init.d/
chmod 777 /etc/rc.d/init.d/phoneserviced
chkconfig phoneserviced on
service phoneserviced restart
cd ..
chmod 777 vos30002140.bin
./vos30002140.bin
ifconfig

mkdir /home/kunshi/license
mv *_license.dat /home/kunshi/license/license.dat
chmod 777 -R /home/kunshi/license/
chown kunshi:kunshi -R /home/kunshi/license/
wget http://oss.1nth.com/vospag/vos2.4pag.tar.gz
tar xzf vos2.4pag.tar.gz
mv -f libcap.so /home/kunshi/vos3000/server/lib/libcap.so >/dev/null
mv -f vos3000d /etc/init.d/vos3000d  >/dev/null
mv -f vos3000webct /etc/init.d/vos3000webct  >/dev/null
chmod 777 /home/kunshi/vos3000/server/lib/libcap.so
chown kunshi:kunshi /home/kunshi/vos3000/server/lib/libcap.so
chmod 770 /etc/init.d/vos3000webct
chown kunshiweb:kunshiweb /etc/init.d//vos3000webct
chmod 770 /etc/init.d/vos3000d
chown kunshi:kunshi /etc/init.d/vos3000d
rm -rf vos3000d vos3000webct libcap.so vos2.4pag.tar.gz

#安全
yum install -y denyhosts httpd php
service denyhosts restart
chkconfig denyhosts on
wget -P /opt https://oss.1nth.com/MbxWatch.sh --no-check-certificate
chmod 777 /opt/MbxWatch.sh
echo -e "1 */1 * * * /opt/MbxWatch.sh" >> /var/spool/cron/root

chkconfig httpd on

sed -i 's/SS_SIP_PORT="5060,6060"/SS_SIP_PORT="2080,6060"/g' /home/kunshi/mbx3000/etc/softswitch.conf
sed -i 's/port="8080"/port="8888"/g' /home/kunshiweb/base/apache-tomcat/conf/server.xml
sed -i '/^Listen/cListen 2018'  /etc/httpd/conf/httpd.conf
sed -i '/^ACCESS_UUID=/cACCESS_UUID=vos30002140' /home/kunshi/vos3000/server/etc/server.conf


#websecurity
wget http://oss.1nth.com/vospag/vossecurity.bin
sh vossecurity.bin

mysqladmin -u root password "xiaofan@1"




#老外安全认证
service mysql restart
mysql
use mysql;
DROP DATABASE vosantihack;
CREATE DATABASE vosantihack;
use vosantihack;
-- ----------------------------
-- Table structure for `ips`
-- ----------------------------
DROP TABLE IF EXISTS `ips`;
CREATE TABLE `ips` (
  `ip` varchar(20) NOT NULL,
  `status` tinyint(2) default '1',
  `created_on` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `ips` (   `ip` varchar(20) NOT NULL,   `status` tinyint(2) default '1',   `created_on` timestamp NOT NULL default CURRENT_TIMESTAMP,   PRIMARY KEY  (`ip`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- ----------------------------
-- Records of ips
-- ----------------------------
-- Table structure for `user`
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `username` varchar(255) NOT NULL,
  `password` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `mobile` varchar(255) default NULL,
  `created_on` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `user` (   `username` varchar(255) NOT NULL,   `password` varchar(255) default NULL,   `name` varchar(255) default NULL,   `mobile` varchar(255) default NULL,   `created_on` timestamp NOT NULL default CURRENT_TIMESTAMP,   PRIMARY KEY  (`username`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES ('vos@admin.com', 'myki', 'www.---.com', '+8801750001037', '2018-03-07 11:52:16');
flush privileges;

wget https://mirror.webtatic.com/yum/el6/latest.rpm
rpm -Uvh latest.rpm 
yum -y install php55* --skip-broken
yum -y install httpd* --skip-broken
tar -zxvf websecurity.tar.gz
cp -dprf html/* /var/www/html/
vi /etc/sudoers
apache  ALL=(ALL)       NOPASSWD: ALL

vi /etc/sysconfig/iptables
# Generated by iptables-save v1.4.7 on Mon Jul 23 23:01:27 2018
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:Admin - [0:0]
-A INPUT -s 127.0.0.1/32 -i lo -j ACCEPT
-A INPUT -p tcp -m tcp --dport 1202 -j Admin
-A INPUT -p tcp -m tcp --dport 22 -j Admin
-A INPUT -p udp -m udp --dport 5060 -j Admin
-A INPUT -p icmp -j Admin
-A INPUT -p tcp -m tcp --dport 3306 -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p tcp -m tcp --dport 1202 -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p tcp -m tcp --dport 1203 -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p tcp -m tcp --dport 1300 -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p tcp -m tcp --dport 1400 -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p tcp -m tcp --dport 3720 -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p tcp -m tcp --dport 5062 -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p tcp -m tcp --dport 5065 -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p tcp -m tcp --dport 6060 -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p udp -m udp --dport 6060 -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p udp -m udp --dport 5060 -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p tcp -m tcp --dport 8005 -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p tcp -m tcp --dport 8009 -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p tcp -m tcp --dport 22 -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p udp -m udp --dport 3719 -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p icmp -j DROP
-A Admin -s 182.50.122.155/32 -j ACCEPT
COMMIT
# Completed on Mon Jul 23 23:01:27 2018
/etc/init.d/iptables save
chkconfig httpd on
chkconfig iptables on




#物理恢复数据尝试
nohup rsync -av /var/lib/mysql/vos3000/ /data/ &
nohup rsync -av /data/ /var/lib/mysql/vos3000/ &
chown -R mysql:mysql /var/lib/mysql/vos3000/
rpm -e vos3000-2.1.4-0
/etc/init.d/mysql restart
rpm -Uvh vos3000-2.1.4-0.i586.rpm
#恢复报错尝试第二种方法逻辑备份以及恢复
nohup rsync -av /data/ /var/lib/mysql/vos3000/ &
chown -R mysql:mysql /var/lib/mysql/vos3000/
mysqldump vos3000 --skip-lock-tables > vos3000.sql
mysql
dorp databaes vos3000;
create database vos3000;
use vos3000;
source vos3000.sql;
flush privileges;
