#!/bin/bash
Install_Redis()
{
    echo "###################Installing PHP Redis #################"
    cd ${base_dir}/src &&  tar xzf phpredis-php7.tgz && cd phpredis-php7
    make clean
    $php_install_dir/bin/phpize
    ./configure --with-php-config=$php_install_dir/bin/php-config
    make && make install
    if [ -f "`$php_install_dir/bin/php-config --extension-dir`/redis.so" ];then
        cat > $php_install_dir/etc/php.d/ext-redis.ini <<EOF
[redis]
extension=redis.so
EOF
        echo "PHP Redis module install successfully!"
        rm -rf ${base_dir}/src/phpredis-php7
        service php-fpm restart
    fi

    echo "###################Installing Redis #################"
    cd ${base_dir}/src &&  tar xzf redis-3.2.0.tar.gz && cd redis-3.2.0
    if [ "${os_bit}" = "64" ] ; then
        make PREFIX=/usr/local/redis install
    else
        make CFLAGS="-march=i686" PREFIX=/usr/local/redis install
    fi

    mkdir -p $redis_install_dir/{bin,etc,var}
    /bin/cp src/{redis-benchmark,redis-check-aof,redis-check-rdb,redis-cli,redis-sentinel,redis-server} $redis_install_dir/bin/
    /bin/cp redis.conf $redis_install_dir/etc/
    ln -s $redis_install_dir/bin/* /usr/local/bin/
    sed -i 's@pidfile.*@pidfile /var/run/redis.pid@' $redis_install_dir/etc/redis.conf
    sed -i "s@logfile.*@logfile $redis_install_dir/var/redis.log@" $redis_install_dir/etc/redis.conf
    sed -i "s@^dir.*@dir $redis_install_dir/var@" $redis_install_dir/etc/redis.conf
    sed -i 's@daemonize no@daemonize yes@' $redis_install_dir/etc/redis.conf
    sed -i "s@^# bind 127.0.0.1@bind 127.0.0.1@" $redis_install_dir/etc/redis.conf
    redis_maxmemory=`expr $memory_total / 8`000000
    [ -z "`grep ^maxmemory $redis_install_dir/etc/redis.conf`" ] && sed -i "s@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory `expr $memory_total / 8`000000@" $redis_install_dir/etc/redis.conf
    echo "Redis-server install successfully! "

    useradd -M -s /sbin/nologin redis
    chown -R redis:redis $redis_install_dir/var/
    /bin/cp ${base_dir}/init.d/redis.sh /etc/init.d/redis-server
    chmod +x /etc/init.d/redis-server
    update-rc.d redis-server defaults
    sed -i "s@/usr/local/redis@$redis_install_dir@g" /etc/init.d/redis-server
    [ -z "`grep 'vm.overcommit_memory' /etc/sysctl.conf`" ] && echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
    [ -z "`grep 'net.core.somaxconn' /etc/sysctl.conf`" ] && echo 'net.core.somaxconn = 65535' >> /etc/sysctl.conf
    [ -z "`grep 'net.ipv4.tcp_max_syn_backlog' /etc/sysctl.conf`" ] && echo 'net.ipv4.tcp_max_syn_backlog = 20480' >> /etc/sysctl.conf
    sysctl -p

    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    service redis-server start

    echo "Redis installed successfully"

    rm -rf ${base_dir}/src/redis-3.2.0
    cd ${base_dir}


}
