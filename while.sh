#!/bin/bash 
b=$[RANDOM%101]
while :
 do 
let c++
read -p "input a number(1-100):" a 
  if [ $a -eq $b ];then
    echo " you are right "
     echo "你猜了$c 次"
     exit 
  elif [ $a -lt $b ];then
   echo " too less "
  else 
    echo " too large "
  fi 
 done 
