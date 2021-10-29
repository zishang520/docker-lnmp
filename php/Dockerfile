FROM php:7.4-fpm-alpine
MAINTAINER None

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

# PHP8.0 以下安装enchant1-开始
RUN apk add autoconf m4 make gcc g++ glib-dev hunspell-dev
ADD ./downloads/enchant.tar.gz /tmp
COPY ./downloads/install-enchant.sh /tmp/install-enchant.sh
RUN sh /tmp/install-enchant.sh
RUN docker-php-ext-install -j$(nproc) enchant
# PHP8.0 以下安装enchant1-结束

# 安装编译需要的包
RUN apk add gettext-dev
RUN docker-php-ext-install -j$(nproc) bcmath calendar exif gettext sockets dba mysqli pcntl pdo_mysql shmop sysvmsg sysvsem sysvshm

# 安装编译需要的包
RUN apk add freetds-dev openldap-dev imap-dev bzip2-dev zlib-dev gd-dev gmp-dev krb5-dev libxml2-dev tidyhtml-dev libxslt-dev libzip-dev net-snmp-dev postgresql-dev aspell-dev

RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
docker-php-ext-configure pdo_dblib && \
docker-php-ext-configure ldap && \
docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
docker-php-ext-install -j$(nproc) bz2 gd gmp soap xmlrpc tidy xsl zip snmp pgsql pdo_pgsql pspell pdo_dblib ldap imap intl

# imagick 扩展
RUN export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" && \
apk add imagemagick-dev && \
pecl install imagick-3.5.1 && \
docker-php-ext-enable imagick

# 增加 Memcached 扩展
RUN apk add libmemcached-dev && \
pecl install memcached && \
docker-php-ext-enable memcached

# redis 扩展
RUN pecl install redis-5.3.4 && docker-php-ext-enable redis

# 增加 opcache 扩展
RUN docker-php-ext-configure opcache --enable-opcache && docker-php-ext-install opcache

# Swoole 扩展安装 开启扩展
RUN pecl install swoole-4.8.0 && docker-php-ext-enable swoole

# Mongodb 扩展安装
RUN pecl install mongodb && docker-php-ext-enable mongodb