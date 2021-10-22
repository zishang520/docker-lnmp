FROM php:7.4-fpm-alpine
MAINTAINER luoyy

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# 设置环境变量
ENV LANG=C.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#docker中php扩展安装方式
#1、PHP源码文件目录自带扩展 docker-php-ext-install直接安装
#2、pecl扩展 因为一些扩展不包含在PHP源码文件中，PHP 的扩展库仓库中存在。用 pecl install 安装扩展，再用 docker-php-ext-enable 命令 启用扩展
#3、其他扩展 一些既不在 PHP 源码包，也不再 PECL 扩展仓库中的扩展，可以通过下载扩展程序源码，编译安装的方式安装

# 扩展依赖
# 官方版本默认安装扩展:
# Core, ctype, curl, date, dom, fileinfo, filter, ftp, hash, iconv, json, libxml, mbstring, mysqlnd, openssl, pcre, PDO, pdo_sqlite, Phar, posix
# readline, Reflection, session, SimpleXML, sodium, SPL, sqlite3, standard, tokenizer, xml, xmlreader, xmlwriter, zlib

# 修改源并更新包
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && apk update && apk upgrade

# 安装编译需要的包
RUN apk add gettext-dev

# 1.0.2 增加 bcmath, calendar, exif, gettext, sockets, dba, mysqli, pcntl, pdo_mysql, shmop, sysvmsg, sysvsem, sysvshm 扩展
RUN docker-php-ext-install -j$(nproc) bcmath calendar exif gettext sockets dba mysqli pcntl pdo_mysql shmop sysvmsg sysvsem sysvshm

# 1.0.3 增加 bz2 扩展, 读写 bzip2（.bz2）压缩文件 (libbz2-dev)。
# 1.0.4 增加 enchant 扩展, 拼写检查库 (libenchant-dev)。
# 1.0.5 增加 GD 扩展. 图像处理 (libfreetype6-dev libjpeg62-turbo-dev libpng-dev)。
# 1.0.6 增加 gmp 扩展, GMP (libgmp-dev)。
# 1.0.7 增加 soap wddx[有错] xmlrpc tidy xsl 扩展 (libxml2-dev libtidy-dev libxslt1-dev)。
# 1.0.8 增加 zip 扩展 (libzip-dev)。
# 1.0.9 增加 snmp 扩展（libsnmp-dev）。
# 1.0.10 增加 pgsql, pdo_pgsql 扩展（libpq-dev）。
# 1.0.11 增加 pspell 扩展 （libpspell-dev）。
# 1.0.12 增加 recode 扩展 （librecode-dev）[有错]。
# 1.0.13 增加 PDO_Firebird 扩展 （firebird-dev）。
# 1.0.14 增加 pdo_dblib 扩展 （freetds-dev）。
# 1.0.15 增加 ldap 扩展 （libldap2-dev）。
# 1.0.16 增加 imap 扩展 （libc-client-dev libkrb5-dev）。
# 1.0.17 增加 interbase 扩展 （firebird-dev）[有错]。
# 1.0.18 增加 intl 扩展 （libicu-dev）。

# 安装编译需要的包
RUN apk add freetds-dev openldap-dev imap-dev bzip2-dev zlib-dev enchant-dev

RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
docker-php-ext-configure pdo_dblib && \
docker-php-ext-configure ldap && \
docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
docker-php-ext-install -j$(nproc) bz2 enchant gd gmp soap xmlrpc tidy xsl zip snmp \
pgsql pdo_pgsql pspell pdo_firebird pdo_dblib ldap imap intl

# 1.0.19 增加 mcrypt 扩展 （7.3以后已废除）
RUN apt-get update && \
apt-get install -y --no-install-recommends libmcrypt-dev && \
rm -r /var/lib/apt/lists/* && \
pecl install mcrypt-1.0.1 && \
docker-php-ext-enable mcrypt

# 1.0.20 imagick 扩展
RUN export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" && \
apt-get update && \
apt-get install -y --no-install-recommends libmagickwand-dev && \
rm -rf /var/lib/apt/lists/* && \
pecl install imagick-3.4.3 && \
docker-php-ext-enable imagick

# 1.0.21 增加 Memcached 扩展
RUN apt-get update && \
apt-get install -y --no-install-recommends zlib1g-dev libmemcached-dev && \
rm -r /var/lib/apt/lists/* && \
pecl install memcached && \
docker-php-ext-enable memcached

# 1.0.22 redis 扩展
RUN pecl install redis-5.1.1 && docker-php-ext-enable redis

# 1.0.23 增加 opcache 扩展
RUN docker-php-ext-configure opcache --enable-opcache && docker-php-ext-install opcache

# Swoole 扩展安装 开启扩展
RUN pecl install swoole-4.4.14 && docker-php-ext-enable swoole

# Mongodb 扩展安装
RUN pecl install mongodb && docker-php-ext-enable mongodb