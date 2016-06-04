#!/bin/bash
Install_Supervisor() {
    echo "###############Installing Supervisord################"
    sudo apt-get install -y supervisor --force-yes
    sed -i "s:files = /etc/supervisor/conf.d/\*.conf:files = conf.d/*.conf:" /etc/supervisor/supervisord.conf
    sudo service supervisor restart
}
