#!/bin/bash
sed -n '/bash$/s/:.*//p' /etc/passwd |while read var;do 
       echo -n "${var}---->" 
  sed -rn "s/${var}:([^:]+).*/\1/p"  /etc/shadow
done
 # var="sed -rn 's/root:([^:]+).*/\1/p'"  /etc/shadow
