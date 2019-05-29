#!/bin/bash
#read -p "please input a num(1-10):" num
#while [[ "$num" != 4 ]]
while :
do  
read -p "please input a num(1-10):" num
   if [ "$num" -lt 4 ]
   then  
       echo "too small"
	   continue
   elif [ "$num" -gt 4 ]
   then  
       echo  "too high"
	   continue
   else
echo "you are right"
   exit 0
   fi 
done
echo "you are right"
