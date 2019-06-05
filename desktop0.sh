#!/bin/bash

##qstat
echo "alias qstat='/bin/ps -Ao pid,tt,user,fname,rsz'" >> /etc/bashrc
source /etc/bashrc

##firewall
firewall-cmd --set-default-zone=trusted
firewall-cmd --permanent --add-source=172.34.0.0/24 --zone=block
firewall-cmd --reload

##team0
nmcli connection add type team con-name team0 ifname team0 config '{"runner":{"name":"activebackup"}}'
nmcli connection add type team-slave con-name team0-1 ifname eth1 master team0
nmcli connection add type team-slave con-name team0-2 ifname eth2 master team0
nmcli connection modify team0 ipv4.method manual ipv4.addresses "172.16.3.25/24" connection.autoconnect yes
nmcli connection up team0

##ipv4
nmcli connection modify 'System eth0' ipv4.method manual ipv4.addresses '172.25.0.10/24 172.25.0.254' ipv4.dns 172.25.254.254 connection.autoconnect yes
hostnamectl set-hostname desktop0.example.com
nmcli connection up 'System eth0'

##ipv6
nmcli connection modify "System eth0" ipv6.method manual ipv6.addresses "2003:ac18::306/64" connection.autoconnect yes
nmcli connection up "System eth0"

lab smtp-nullclient setup

##samba
firewall-cmd --set-default-zone=trusted
yum -y install samba-client.x86_64 cifs-utils.x86_64
mkdir /mnt/dev
cat >> /etc/fstab <<A
//server0.example.com/devops /mnt/dev cifs user=kenji,pass=atenorth,multiuser,sec=ntlmssp,_netdev  0   0
A

##iscsi
yum -y install iscsi-initiator-utils
echo 'InitiatorName=iqn.2016-02.com.example:desktop0
 ' >/etc/iscsi/initiatorname.iscsi
systemctl start iscsid 

iscsiadm --mode discoverydb --type sendtargets --portal 172.25.0.11 --discover
systemctl enable iscsid 

cd /var/lib/iscsi/nodes/iqn.2016-02.com.example\:server0/172.25.0.11\,3260\,1/
cp -p default default.bak
head -49 default.bak > default
echo "node.conn[0].startup = automatic " >> default
tail -13 default.bak >> default
systemctl daemon-reload
systemctl restart  iscsi
systemctl enable  iscsi
echo 'n 



+2100M
w
' | fdisk /dev/sda
partprobe /dev/sda
mkfs.ext4 /dev/sda1
cd /root/
echo "$(blkid | grep /dev/sda1|cut -d " " -f 2) /mnt/data ext4 _netdev 0  0 " >> /etc/fstab
mkdir /mnt/data
sync

#desktop0 nfs
lab nfskrb5 setup
mkdir /mnt/nfs{secure,mount}
wget -O /etc/krb5.keytab http://classroom.example.com/pub/keytabs/desktop0.keytab
systemctl restart nfs-secure
systemctl enable nfs-secure
echo 'server0.example.com:/public /mnt/nfsmount nfs _netdev 0 0
server0.example.com:/protected /mnt/nfssecure nfs sec=krb5p,_netdev 0 0' >> /etc/fstab
mount -a


