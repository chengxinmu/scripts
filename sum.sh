#!/bin/bash
#for i in {0..100..2}
#do 
#  let "sum+=i"
#done
#echo "sum=$sum"
i=1
sum=0
while (( i <= 100 ))
do 
   let "sum+=i"
   let "i+=2"
done
echo  "sum=$sum"
