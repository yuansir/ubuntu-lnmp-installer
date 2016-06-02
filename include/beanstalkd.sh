#!/bin/bash
Install_Beanstalkd() {
    echo "############Installing Beanstalkd##########"

    apt-get install -y beanstalkd --force-yes
    sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd
    service beanstalkd start
}
