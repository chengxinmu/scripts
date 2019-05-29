#!/bin/bash
ping -c 3 -i 0.2 -w 1 $1 &> /dev/null
if [ $? -eq 0 ];then
    echo good 
else 
    echo bad 
fi   
