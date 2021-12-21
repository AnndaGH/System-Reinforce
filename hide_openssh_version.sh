#!/bin/bash
# ----------------------------------------
# Hide OpenSSH Version Script
# Ver 1.0 Update 2021/12/21
# Author Annda
# ----------------------------------------
# check openssh version
exec 3<> /dev/tcp/127.0.0.1/22
echo 1>&3
version=`tr -d '\0' <&3 | grep -Po '(?<=SSH-2.0-)OpenSSH_\d.\d'`
[ -z $version ] && echo already hide openssh version && exit 0
# default replace version to SurpriseOwO
str=${1-'SurpriseOwO'}
replace=`echo ${str:0:${#version}} | xargs printf "%-"${#version}"s"`
# modify binary
echo "hide: $version to $replace"
[ `command -v strings` ] || yum -y install binutils
[ `command -v strings` ] || (echo binutils install failed; exit 1)
loc=`strings -t d -a -n 7 /usr/sbin/sshd | grep -Po '\d+(?=\s'$version'$)'`
# part 1 
dd if=/usr/sbin/sshd bs=1 count=$loc of=/tmp/sshd.1
# part 2
echo -n "$replace" > /tmp/sshd.2
# part 3
dd if=/usr/sbin/sshd bs=1 skip=$[$loc+${#version}] count=999999999 of=/tmp/sshd.3
# merge
cat /tmp/sshd.1 /tmp/sshd.2 /tmp/sshd.3 > /tmp/sshd.new
chmod 755 /tmp/sshd.new
\cp -f /usr/sbin/sshd{,.bak}
\cp -f /tmp/sshd.new /usr/sbin/sshd
echo hide openssh version complete.
