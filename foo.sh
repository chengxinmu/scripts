#!/bin/bash
r=`\033[31m  \033[32m  \033[33m  \033[34m  \033[0m`
astr=" o-o-o-o>"
for i in {0..60};do 
    echo -ne  "${i,r++}"
    echo -ne "\033[60G${i}%"
    echo -ne "\033[${i}G${astr}"
    sleep 0.2
done
           
