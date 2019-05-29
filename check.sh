#!/bin/bash
rip1=192.168.4.12
rip2=192.168.4.13
vip=192.168.4.15
a="0cc0b5fc62af6f35638b637ecb990fb8  -"
b="4e803e5e07f95a7f820591cca94b2753  -"
i=0
while [[ i -lt 20 ]]
  do
   let i++
    for ip in $rip1 $rip2
	do
    c=$(curl -s $ip | md5sum )
	if [ "$c" == "$a" ] || [ "$c" == "$b" ];then
	   echo everything is ok
	#   exit 0
	#   elif  [ "$c" != "$a" ] && [ "$c" != "$b" ];then
	else
	   echo $ip is wrong
	#   exit 2
	fi
    done
  sleep 2
  done
       


















#while :
#  do
# # for ip in $rip1 $rip2 
# # do
# # curl -s $ip | md5sum &> /dev/null 
#  c=$(curl -s $rip1 | md5sum)
#  d=$(curl -s $rip2 | md5sum)
#    for md5 in $a $b
#	do
#       if [ "$c" == "$md5" ] || [ "$d" == "$md5" ];then
#        echo "every thing is ok"
#	    else 
#	    echo "$ip is wrong"
#       fi
#	done
#	sleep 1
#  done
#
    
