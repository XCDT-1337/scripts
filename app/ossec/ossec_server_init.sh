#!/bin/bash
#assumes a root session
cd /root/
echo "installing required packages"
apt-get install -y build-essential make libssl-dev git strings
apt-get install -y mysql-server libmysqlclient-dev mysql-client apache2 php5 libapache2-mod-php5 php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl
echo "accept the options"
mysql_secure_installation
/etc/init.d/apache2 restart
/etc/init.d/mysql restart
echo "installing ossec-hids"
wget https://bintray.com/artifact/download/ossec/ossec-hids/ossec-hids-2.8.3.tar.gz
tar -xf ossec-hids-2.8.3.tar.gz
cd ossec-hids-2.8.3
cd src
make setdb
cd ../
echo "configure and copy info"
./install.sh
/var/ossec/bin/ossec-control restart
echo "setup mysql DB 1. > create database ossec; 2. grant INSERT,SELECT,UPDATE,CREATE,DELETE,EXECUTE on ossec.* to ossec_u; \n3. set password for ossec_u = PASSWORD('Passw0rd'); 4. flush privileges; 5;. quit;"
mysql -u root -p
echo "input mysql password"
read -rsp mysqlpass
mysql -u root -p $mysqlpass < src/os_dbd/mysql.schema
sed -e "\$a\n<ossec_config>\n\t<database_output>\n\t\t<hostname>127.0.0.1</hostname>\n\t\t<username>ossec_u</username>\n\t\t<password>Passw0rd</password>\n\t\t<database>ossec</database>\n\t\t<type>mysql</type>\n\t</database_output>/n</ossec_config>"
/var/ossec/bin/ossec-control enable database
/var/ossec/bin/ossec-control restart
echo "installing web UI"
wget https://github.com/ossec/ossec-wui/archive/0.9.tar.gz
tar -xf ossec-wui-0.9.tar.gz
mkdir -p /var/www/html/ossec/tmp/
mv ossec-wui-0.9/* /var/www/html/ossec/
chown www-data:www-data /var/www/html/ossec/tmp/
chmod 666 /var/www/html/ossec/tmp
usermod -a -G ossec www-data
