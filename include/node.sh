#!/bin/bash
Install_Node() {
    echo "#############Install Node###################"
    cd ${base_dir}/src && tar zxf node-v5.8.0.tar.gz && cd node-v5.8.0
    ./configure
    make && make install
    echo "Node.js install successfully!"

    alias cnpm="npm --registry=https://registry.npm.taobao.org --cache=$HOME/.npm/.cache/cnpm --disturl=https://npm.taobao.org/dist \--userconfig=$HOME/.cnpmrc"

    cnpm install pm2 -g
    rm -rf  ${base_dir}/src/node-v5.8.0
    cd ${base_dir}
}
