#!/bin/bash 
s=0  f=0
for i in {1..15}
do 
 ping -c 3 -i 0.2 -w 1 172.25.0.$i &> /dev/nulil
  if [ $? -eq 0 ];then
     echo "172.25.0.$i is ok"
     let s++
  else 
     echo "172.25.0.$i is no"
     let f++
  fi
done
  echo $s is ok $f is no
