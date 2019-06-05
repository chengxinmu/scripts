#!/bin/bash
##samba
firewall-cmd --set-default-zone=trusted
yum -y install samba-client.x86_64 cifs-utils.x86_64
mkdir /mnt/dev
cat >> /etc/fstab <<A
//server0.example.com/devops /mnt/dev cifs user=kenji,pass=atenorth,multiuser,sec=ntlmssp,_netdev  0   0
A
mount -a 

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
cd ~
echo "$(blkid | grep /dev/sda1|cut -d " " -f 2) /mnt/data ext4 _netdev 0  0 " >> /etc/fstab
mkdir /mnt/data
mount -a
sync




