#!/bin/sh
path() {
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
}

main(){
    cd /tmp/enchant-1.6.1
    ./configure --prefix=/usr
    make -j$(nproc)
    make install
    exit
}
path
main