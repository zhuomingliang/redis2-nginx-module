#!/bin/bash

# this file is mostly meant to be used by the author himself.

ragel -I src -G2 src/ngx_http_redis2_reply.rl || exit 1

root=`pwd`
#cd ~/work
version=$1
#opts=$2
home=~
target=$root/work/nginx

if [ ! -d ./buildroot ]; then
    mkdir ./buildroot || exit 1
fi

cd buildroot || exit 1

if [ ! -s "nginx-$version.tar.gz" ]; then
    if [ -f ~/work/nginx-$version.tar.gz ]; then
        cp ~/work/nginx-$version.tar.gz ./ || exit 1
    else
        wget "http://sysoev.ru/nginx/nginx-$version.tar.gz" -O nginx-$version.tar.gz || exit 1
    fi

    tar -xzvf nginx-$version.tar.gz || exit 1
    cp $root/../no-pool-nginx/nginx-$version-no_pool.patch ./ || exit 1
    patch -p0 < nginx-$version-no_pool.patch || exit 1
fi

#patch -p0 < ~/work/nginx-$version-rewrite_phase_fix.patch || exit 1

cd nginx-$version/ || exit 1

if [[ "$BUILD_CLEAN" -eq 1 || ! -f Makefile || "$root/config" -nt Makefile || "$root/util/build.sh" -nt Makefile ]]; then
          #--with-cc-opt="-O3" \
          #--with-cc-opt="-fast" \
    ./configure --prefix=$target \
          --with-http_addition_module \
          --add-module=$root $opts \
          --add-module=$root/../eval-nginx-module \
          --add-module=$root/../echo-nginx-module \
          --add-module=$root/../ndk-nginx-module \
          --add-module=$root/../set-misc-nginx-module \
          --add-module=$root/../lua-nginx-module \
          --add-module=$home/work/nginx/ngx_http_upstream_keepalive-c6396fef9295 \
          --with-debug
          #--add-module=$root/../eval-nginx-module \
          #--add-module=$home/work/nginx/nginx_upstream_hash-0.3 \
  #--without-http_ssi_module  # we cannot disable ssi because echo_location_async depends on it (i dunno why?!)

fi
if [ -f $target/sbin/nginx ]; then
    rm -f $target/sbin/nginx
fi
if [ -f $target/logs/nginx.pid ]; then
    kill `cat $target/logs/nginx.pid`
fi
make -j3 && make install

