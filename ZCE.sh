#!/bin/bash 

#SSH
echo "Denyusers  *@*.my133t.org *@172.34.0.* " >> /etc/ssh/sshd_config
systemctl restart sshd
systemctl enable sshd

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


##ipv6

#nmcli connection modify "System eth0" ipv6.method manual ipv6.addresses "2003:ac18::305/64" connection.autoconnect yes 
#nmcli connection up "System eth0"

##samba

yum -y install samba
mkdir /common
useradd harry
echo 'migwhisk
migwhisk'| pdbedit -a harry
setsebool -P samba_export_all_ro=on
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

##iscsi
echo '
n
 
 
 
+3G
w
' | fdisk /dev/vdb
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

