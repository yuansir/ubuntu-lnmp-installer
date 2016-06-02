#!/bin/bash
Install_Jemalloc()
{
    echo "###################Installing Jemalloc################"
    cd ${base_dir}/src
    tar jxf jemalloc-4.2.0.tar.bz2
    cd jemalloc-4.2.0
    ./configure
    make && make install
    ldconfig
    rm -rf ${base_dir}/src/jemalloc-4.2.0
    cd ${base_dir}
}
