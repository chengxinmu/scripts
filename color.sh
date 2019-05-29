#!/bin/bash
color=('\033[0m' '\033[31m' '\033[32m' '\033[33m' '\033[0m')
for i in {99..0};do
id=$((i%5))
echo -ne "id: ${color[${id}]}${i}\r${color[0]}"
sleep 0.5
done
