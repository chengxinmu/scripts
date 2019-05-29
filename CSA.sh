#!/bin/bash
# set ip
hostnamectl set-hostname server0.example.com
nmcli connection modify "System eth0" ipv4.method manual ipv4.addresses "172.25.0.11/24 172.25.0.254" ipv4.dns 172.25.254.254 connection.autoconnect yes
nmcli connection up "System eth0"  
#yum 

rm -rf /etc/yum.repos.d/*.repo
echo '[dvd]
name=dvd
baseurl=http://content.example.com/rhel7.0/x86_64/dvd
enabled=1
gpgcheck=0'> /etc/yum.repos.d/dvd.repo
yum clean all
yum repolist

##lvcreate 
echo '
n



+300M
n



+500M
n



+2G
n



n

+512M
w
' | fdisk /dev/vdb
partprobe
vgcreate systemvg /dev/vdb1
lvcreate -n vo -L 200M systemvg
mkfs.ext3 /dev/systemvg/vo
vgextend systemvg /dev/vdb2
lvextend -L 300M /dev/systemvg/vo
resize2fs /dev/systemvg/vo


echo '/dev/systemvg/vo  /vo   ext3  defaults 0  0' >> /etc/fstab
mkdir /vo 
mount -a 
#useradd

groupadd adminuser
useradd -G adminuser natasha
useradd -G adminuser harry 
useradd -s /sbin/nologin sarah 
echo flectrag | passwd --stdin natasha
echo flectrag | passwd --stdin harry
echo flectrag | passwd --stdin sarah 
cp /etc/fstab /var/tmp/fstab
setfacl -m u:natasha:rw /var/tmp/fstab
setfacl -m u:harry:- /var/tmp/fstab

#set crond 

echo "23 14 * * * /bin/echo hiya" > /var/spool/cron/root
systemctl restart crond 
systemctl enable crond

#set admin


mkdir /home/admins
chown :adminuser /home/admins
chmod 2770  /home/admins

##linux kernel 
wget http://classroom.example.com/content/rhel7.0/x86_64/errata/Packages/kernel-3.10.0-123.1.2.el7.x86_64.rpm
yum -y install kernel-3.10.0-123.1.2.el7.x86_64.rpm

#autofs 
lab nfskrb5 setup
yum -y install sssd
yum -y install autofs 
mkdir /home/guests
echo "/home/guests  /etc/auto.guests" >> /etc/auto.master
echo "* -rw classroom.example.com:/home/guests/& " > /etc/auto.guests
systemctl restart autofs 
systemctl enable autofs 


##chrony
yum -y install chrony

useradd -u 3456 alex 
echo flectrag | passwd --stdin alex 

##swap

echo "/dev/vdb5  swap swap defaults 0  0" >> /etc/fstab
swapon -a 
swapon -s 

##find 
mkdir /root/findfiles 
find / -user student -type f -exec cp -p {} /root/findfiles/ \;

##grep 
grep seismic /usr/share/dict/words > /root/wordlist

##vgcreate 
vgcreate -s 16M datastore  /dev/vdb3
lvcreate -l 50 -n database datastore
mkfs.ext3  /dev/datastore/database
mkdir /mnt/database 
echo "/dev/datastore/database /mnt/database  ext3 defaults 0  0" >> /etc/fstab
mount -a 

##tar 
tar -jcPf  /root/backup.tar.bz2 /usr/local 

##chrony
cp -p /etc/chrony.conf  /etc/chrony.bak
echo "server classroom.example.com iburst " > /etc/chrony.conf
tail -40 /etc/chrony.bak  >> /etc/chrony.conf 
systemctl restart chronyd
systemctl enable chronyd
timedatectl 
reboot
