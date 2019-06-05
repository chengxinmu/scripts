#!/bin/bash

##qstat
echo "alias qstat='/bin/ps -Ao pid,tt,user,fname,rsz'" >> /etc/bashrc
source /etc/bashrc 

##firewall
firewall-cmd --set-default-zone=trusted
firewall-cmd --permanent --add-source=172.34.0.0/24 --zone=block
firewall-cmd --permanent --zone=trusted --add-forward-port=port=5423:proto=tcp:toport=80
firewall-cmd --reload

##team0
nmcli connection add type team con-name team0 ifname team0 config '{"runner":{"name":"activebackup"}}'
nmcli connection add type team-slave con-name team0-1 ifname eth1 master team0
nmcli connection add type team-slave con-name team0-2 ifname eth2 master team0
nmcli connection modify team0 ipv4.method manual ipv4.addresses "172.16.3.20/24" connection.autoconnect yes 
nmcli connection up team0
nmcli connection up team0-1
nmcli connection up team0-2
teamdctl team0 state

##ipv4
nmcli connection modify 'System eth0' ipv4.method manual ipv4.addresses '172.25.0.11/24 172.25.0.254' ipv4.dns 172.25.254.254 connection.autoconnect yes
hostnamectl set-hostname server0.example.com
nmcli connection up 'System eth0'

##ipv6

nmcli connection modify "System eth0" ipv6.method manual ipv6.addresses "2003:ac18::305/64" connection.autoconnect yes 
nmcli connection up "System eth0"

##mail
lab smtp-nullclient setup
cp /etc/postfix/main.cf /etc/postfix/main.cf.bak
head -98 /etc/postfix/main.cf.bak > /etc/postfix/main.cf
echo 'myorigin = desktop0.example.com' >> /etc/postfix/main.cf
echo 'inet_interfaces = loopback-only' >> /etc/postfix/main.cf
head -163 /etc/postfix/main.cf.bak | tail -47 >> /etc/postfix/main.cf
echo 'mydestination = ' >> /etc/postfix/main.cf
echo 'unknown_local_recipient_reject_code = 550' >> /etc/postfix/main.cf
echo 'mynetworks = 127.0.0.0/8 [::1]/128' >> /etc/postfix/main.cf
echo 'relayhost = [smtp0.example.com]' >> /etc/postfix/main.cf
tail -300 /etc/postfix/main.cf.bak >> /etc/postfix/main.cf
echo 'local_transport = error:local delivery disabled' >> /etc/postfix/main.cf
systemctl restart postfix
systemctl enable postfix
echo '123456' | mail -s “dai” student

#swap
echo '
n
 
 
 
+3G
n



+1G
w
' | fdisk /dev/vdb
mkswap /dev/vdb2
echo '/dev/vdb2 swap swap defaults 0 0'>>/etc/fstab
swapon -a


##samba
yum -y install samba
mkdir /common
useradd harry
echo 'migwhisk
migwhisk'| pdbedit -a harry
#setsebool -P samba_export_all_ro=on
setsebool -P samba_export_all_rw=on
cp -p /etc/samba/smb.conf  /etc/samba/smb.bak
grep -Pv "^#|^;|^$" /etc/samba/smb.bak > /etc/samba/smb.conf
cp -p /etc/samba/smb.conf /etc/samba/smb.bak2
tail -27 /etc/samba/smb.conf > /etc/samba/smb.bak2
echo '[golbal]
 workgroup = STAFF'> /etc/samba/smb.conf
cat /etc/samba/smb.bak2 >> /etc/samba/smb.conf
echo '[common]
 path = /common
 hosts allow = 172.25.0.0/24 '>> /etc/samba/smb.conf
mkdir /devops
useradd kenji
useradd chihiro
echo 'atenorth
atenorth' | pdbedit -a kenji
echo 'atenorth
atenorth' | pdbedit -a chihiro
setfacl -m u:chihiro:rwx /devops/
echo '[devops]
 path = /devops
 hosts allow = 172.25.0.0/24 
 write list = chihiro'>> /etc/samba/smb.conf

systemctl restart smb
systemctl enable smb


##nfs-server
lab nfskrb5 setup
mkdir -p /public /protected/project
chown ldapuser0 /protected/project
echo '/public 172.25.0.0/24(ro)
/protected 172.25.0.0/24(rw,sec=krb5p)' > /etc/exports
wget -O /etc/krb5.keytab http://classroom.example.com/pub/keytabs/server0.keytab
systemctl restart nfs-secure-server nfs-server
systemctl enable nfs-secure-server nfs-server

##iscsi
yum -y install targetcli
echo '
backstores/block create iscsi_store /dev/vdb1
 
iscsi/ create iqn.2016-02.com.example:server0
 
iscsi/iqn.2016-02.com.example:server0/tpg1/acls create iqn.2016-02.com.example:desktop0
 
iscsi/iqn.2016-02.com.example:server0/tpg1/luns create /backstores/block/iscsi_store
 
iscsi/iqn.2016-02.com.example:server0/tpg1/portals create 172.25.0.11 3260
 
saveconfig
 
exit
 ' | targetcli
systemctl restart target
systemctl enable target

##web http
yum -y install httpd mod_ssl mod_wsgi
echo '<virtualhost *:80>
  ServerName server0.example.com
  DocumentRoot /var/www/html
</virtualhost>
<virtualhost *:80>
  ServerName www0.example.com
  DocumentRoot /var/www/virtual
</virtualhost>
Listen 8909
<virtualhost *:8909>
  ServerName webapp0.example.com
  DocumentRoot /var/www/webapp0
  WSGIScriptAlias / /var/www/webapp0/webinfo.wsgi
</virtualhost>
<Directory /var/www/html/private>
  Require ip 127.0.0.1 ::1 172.25.0.11
</Directory>
' > /etc/httpd/conf.d/nsd.conf
cd /etc/pki/tls/certs
wget http://classroom.example.com/pub/tls/certs/server0.crt
wget http://classroom.example.com/pub/example-ca.crt
cd ..;cd private
wget http://classroom.example.com/pub/tls/private/server0.key
cd /root/
cp -p /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bak
head -99 /etc/httpd/conf.d/ssl.conf.bak > /etc/httpd/conf.d/ssl.conf
echo 'SSLCertificateFile /etc/pki/tls/certs/server0.crt
SSLCertificateKeyFile /etc/pki/tls/private/server0.key
SSLCACertificateFile /etc/pki/tls/certs/example-ca.crt' >> /etc/httpd/conf.d/ssl.conf
tail -117 /etc/httpd/conf.d/ssl.conf.bak >> /etc/httpd/conf.d/ssl.conf
mkdir /var/www/{webapp0,virtual,www0} /var/www/html/private
wget -O /var/www/virtual/index.html http://classroom.example.com/pub/materials/www.html
wget -O /var/www/html/private/index.html http://classroom.example.com/pub/materials/private.html
wget -O /var/www/webapp0/webinfo.wsgi http://classroom.example.com/pub/materials/webinfo.wsgi
wget -O /var/www/html/index.html http://classroom.example.com/pub/materials/station.html
semanage port -a -t http_port_t -p tcp 8909
useradd fleyd
setfacl -m u:fleyd:rwx /var/www/virtual/
systemctl restart httpd
systemctl enable httpd

##shell
echo '#!/bin/bash
if [ $# -eq 0 ];then
  echo "Usage: /root/batchusers <userfile>"
  exit 1
fi
if [ ! -f $1 ];then
  echo "Input file not found"
  exit 2
fi
for name in `cat $1`
do
  useradd -s /bin/false  $name > /dev/null
done' > /root/batchusers
chmod +x /root/batchusers
echo '#!/bin/bash
if [ "$1" = redhat ];then
  echo fedora
elif [ "$1" = fedora ];then
  echo redhat
else
  echo "root/foo.sh redhat | fedora" >&2
fi ' > /root/foo.sh
chmod +x /root/foo.sh

#MariaDB
yum -y install mariadb-server mariadb
cp -p /etc/my.cnf /etc/my.cnf.bak
echo '[mysqld]
skip-networking' > /etc/my.cnf
tail -18 /etc/my.cnf.bak >> /etc/my.cnf
systemctl restart mariadb
systemctl enable mariadb
mysqladmin -uroot password 'atenorth'
mysql -uroot -patenorth -e "create database Contacts;"
mysql -uroot -patenorth -e "grant select on Contacts.* to Raikon@localhost identified by 'atenorth';"
mysql -uroot -patenorth -e "delete from mysql.user where password='';"
wget http://classroom.example.com/pub/materials/users.sql
mysql -u root -patenorth Contacts < users.sql

