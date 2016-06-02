#!/bin/bash
Install_Nginx() {
    echo "###################Install Nginx##############"
    cd ${base_dir}/src

    tar xzf pcre-8.36.tar.gz
    tar xzf nginx-1.10.0.tar.gz && cd nginx-1.10.0

    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc

    [ ! -d "$nginx_install_dir" ] && mkdir -p $nginx_install_dir
    ./configure --prefix=$nginx_install_dir --user=$run_user --group=$run_user --with-http_stub_status_module --with-http_v2_module --with-http_ssl_module --with-ipv6 --with-http_gzip_static_module --with-http_realip_module --with-http_flv_module --with-pcre=../pcre-8.36 --with-pcre-jit --with-ld-opt='-ljemalloc'
    make && make install

    echo "Nginx install successfully!"

    [ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=$nginx_install_dir/sbin:\$PATH" >> /etc/profile
    [ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep $nginx_install_dir /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=$nginx_install_dir/sbin:\1@" /etc/profile
    . /etc/profile

    chown -R ${run_user}:${run_user} ${www_dir}

    /bin/cp ${base_dir}/init.d/nginx.sh /etc/init.d/nginx; update-rc.d nginx defaults;
    /bin/cp ${base_dir}/config/nginx.conf $nginx_install_dir/conf/nginx.conf
    /bin/cp ${base_dir}/config/proxy.conf $nginx_install_dir/conf/proxy.conf

    sed -i "s@/usr/local/nginx@$nginx_install_dir@g" /etc/init.d/nginx
    chmod +x /etc/init.d/nginx
    sed -i "s@/data/wwwroot/default@$www_dir/default@" $nginx_install_dir/conf/nginx.conf
    sed -i "s@/data/wwwlogs@$logs_dir@g" $nginx_install_dir/conf/nginx.conf
    sed -i "s@^user www www@user $run_user $run_user@" $nginx_install_dir/conf/nginx.conf

    # logrotate nginx log
    cat > /etc/logrotate.d/nginx<<EOF
$logs_dir/*nginx.log {
daily
rotate 5
missingok
dateext
compress
notifempty
sharedscripts
postrotate
    [ -e /var/run/nginx.pid ] && kill -USR1 \`cat /var/run/nginx.pid\`
endscript
}
EOF

    # ldconfig
    service nginx start

    rm -rf  ${base_dir}/src/nginx-1.10.0
    rm -rf  ${base_dir}/src/pcre-8.36
    cd ${base_dir}
}
