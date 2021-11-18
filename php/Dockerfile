ARG LNMP_PHP_VERSION
FROM php:${LNMP_PHP_VERSION}-fpm-alpine

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

RUN apk --update add wget \
  curl \
  build-base \
  libmcrypt-dev \
  libxml2-dev \
  linux-headers \
  pcre-dev \
  zlib-dev \
  autoconf \
  cyrus-sasl-dev \
  libgsasl-dev \
  oniguruma-dev \
  libressl \
  libressl-dev

RUN set -eux; \
  pecl channel-update pecl.php.net

# Install enchant package
RUN if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
  apk --update add php7-enchant && \
  sh -c 'echo "extension=/usr/lib/php7/modules/enchant.so" > /usr/local/etc/php/conf.d/enchant.ini' \
  else \
  apk add enchant2-dev; \
  docker-php-ext-install -j$(nproc) enchant; \
  ;fi

# 安装编译需要的包
RUN apk add gettext-dev
RUN docker-php-ext-install -j$(nproc) bcmath calendar exif gettext sockets dba mysqli pcntl pdo_mysql shmop sysvmsg sysvsem sysvshm

# 安装编译需要的包
RUN apk add freetds-dev openldap-dev imap-dev bzip2-dev zlib-dev gmp-dev krb5-dev libxml2-dev tidyhtml-dev libxslt-dev libzip-dev net-snmp-dev postgresql-dev hunspell-dev aspell-dev

RUN docker-php-ext-configure pdo_dblib && \
docker-php-ext-configure ldap && \
docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
docker-php-ext-install -j$(nproc) bz2 gmp soap xmlrpc tidy xsl zip snmp pgsql pdo_pgsql pspell pdo_dblib ldap imap intl

# gd 扩展
RUN set -eux; \
  apk add --update --no-cache gd-dev freetype-dev libwebp-dev libjpeg-turbo-dev jpeg-dev libpng-dev; \
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ] && [ $(php -r "echo PHP_MINOR_VERSION;") = "4" ]; then \
  docker-php-ext-configure gd --with-freetype --with-jpeg --with-png  --with-webp; \
  else \
  docker-php-ext-configure gd --with-freetype-dir=/usr/lib/ --with-jpeg-dir=/usr/lib/ --with-png-dir=/usr/lib/ --with-webp-dir=/usr/lib/; \
  fi; \
  docker-php-ext-install gd

# imagick 扩展
ARG IMAGEMAGICK_VERSION=latest
ENV IMAGEMAGICK_VERSION ${IMAGEMAGICK_VERSION}
RUN set -eux; \
  apk add --update --no-cache imagemagick-dev imagemagick; \
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
  cd /tmp && \
  if [ ${IMAGEMAGICK_VERSION} = "latest" ]; then \
  git clone https://github.com/Imagick/imagick; \
  else \
  git clone --branch ${IMAGEMAGICK_VERSION} https://github.com/Imagick/imagick; \
  fi && \
  cd imagick && \
  phpize && \
  ./configure && \
  make && \
  make install && \
  rm -r /tmp/imagick; \
  else \
  pecl install imagick; \
  fi && \
  docker-php-ext-enable imagick; \
  php -m | grep -q 'imagick'

# 增加 Memcached 扩展
RUN apk --update add libmemcached-dev; \
  # Install the php memcached extension
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
  pecl install memcached-2.2.0; \
  else \
  pecl install memcached; \
  fi; \
  docker-php-ext-enable memcached; \
  php -m | grep -r 'memcached'

# redis 扩展
RUN if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
  printf "\n" | pecl install -o -f redis-4.3.0; \
  else \
  printf "\n" | pecl install -o -f redis; \
  fi; \
  rm -rf /tmp/pear; \
  docker-php-ext-enable redis

# 增加 opcache 扩展
RUN docker-php-ext-configure opcache --enable-opcache && docker-php-ext-install opcache

# Swoole 扩展安装 开启扩展
RUN set -eux; \
    # Install Php Swoole Extension
    if   [ $(php -r "echo PHP_VERSION_ID - PHP_RELEASE_VERSION;") = "50600" ]; then \
      pecl install swoole-2.0.10; \
    elif [ $(php -r "echo PHP_VERSION_ID - PHP_RELEASE_VERSION;") = "70000" ]; then \
      pecl install swoole-4.3.5; \
    elif [ $(php -r "echo PHP_VERSION_ID - PHP_RELEASE_VERSION;") = "70100" ]; then \
      pecl install swoole-4.5.11; \
    else \
      pecl install swoole; \
    fi; \
    docker-php-ext-enable swoole; \
    php -m | grep -oiE '^swoole$';

# Mongodb 扩展安装
RUN if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      pecl install mongo; \
      docker-php-ext-enable mongo; \
      php -m | grep -oiE '^mongo$'; \
    else \
      if [ $(php -r "echo PHP_VERSION_ID - PHP_RELEASE_VERSION;") = "70000" ]; then \
        pecl install mongodb-1.9.2; \
      else \
        pecl install mongodb; \
      fi; \
      docker-php-ext-enable mongodb; \
      php -m | grep -oiE '^mongodb$'; \
    fi

RUN rm /var/cache/apk/* \
  && mkdir -p /www