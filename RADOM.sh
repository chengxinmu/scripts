#!/bin/bash 
a=$[RANDOM%11]
read -p "please give me a number(1-10):"  s 
if [ $s -eq $a ];then
  echo "you are right"
elif [ $s -lt $a ];then
  echo "too small"
else
  echo "too large"
fi   

