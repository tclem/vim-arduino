#!/bin/bash

for i in $(ps aux | grep \/dev\/tty.usb | awk '{print $2}')
do 
    kill $i > /dev/null 2>&1
done
