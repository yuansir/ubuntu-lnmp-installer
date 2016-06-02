#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#check if root user
if [ $(id -u) != "0" ]; then
    echo 'just for root user to install !'
    exit 1
fi

#check os
if ! [ -n "`grep Ubuntu /etc/issue`" -o "`lsb_release -is 2>/dev/null`" == 'Ubuntu' ]; then
    echo 'just for ubuntu os !'
    exit 1
fi

#check memory
memory_total=`free -m | grep Mem | awk '{print $2}'`
if [ $memory_total -lt 1024 ]; then
    echo 'Memory should be more than 1024M'
    exit 1
fi

if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ];then
    os_bit=64
else
    os_bit=32
fi

base_dir=$(pwd)

echo $base_dir

. setting.conf
. init.sh

mkdir -p $www_dir/default $logs_dir
[ -d /data ] && chmod 755 /data

id -u ${run_user} >/dev/null 2>&1
[ $? -ne 0 ] && useradd -M -s /sbin/nologin ${run_user}

#install jemalloc
. ./include/jemalloc.sh
Install_Jemalloc

#install mysql
. ./include/mysql.sh
Install_MySQL

#install php
. ./include/php.sh
Install_PHP

#install nginx
. ./include/nginx.sh
Install_Nginx

#install redis
. ./include/redis.sh
Install_Redis

#install node.js
. ./include/node.sh
Install_Node

#install beanstalkd
. ./include/beanstalkd.sh
Install_Beanstalkd

#install Supervisord
. ./include/supervisor.sh
Install_Supervisor

echo "---- Over -----"
