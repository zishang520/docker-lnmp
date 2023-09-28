ARG LNMP_PHP_VERSION
FROM php:${LNMP_PHP_VERSION}-fpm-alpine
MAINTAINER None

ARG LNMP_PHP_VERSION

ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Change application source from dl-cdn.alpinelinux.org to aliyun source
RUN sed -i -e 's/http:/https:/g' /etc/apk/repositories && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk update

RUN apk add --no-cache --update --no-progress wget \
  curl \
  curl-dev \
  git \
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
  openssl \
  openssl-dev \
  gettext-dev \
  icu-dev \
  icu-data-full


RUN pecl channel-update pecl.php.net; \
  docker-php-ext-install mbstring pdo pdo_mysql xml; \
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ] && [ $(php -r "echo PHP_MINOR_VERSION;") = "1" ]; then \
    php -m | grep -q 'tokenizer'; \
  else \
    docker-php-ext-install tokenizer; \
  fi

# Add a non-root user:
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN addgroup -g ${PGID} www && \
  adduser -D -G www -u ${PUID} www

#Install GD package:
ARG INSTALL_GD=true
RUN if [ ${INSTALL_GD} = true ]; then \
  apk add --no-cache --update --no-progress freetype freetype-dev libjpeg-turbo-dev jpeg-dev libpng-dev libwebp-dev libxpm-dev; \
  if { [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ] && [ $(php -r "echo PHP_MINOR_VERSION;") = "4" ] ;} || [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
  docker-php-ext-configure gd --prefix=/usr --with-freetype --with-jpeg --with-webp --with-xpm; \
  else \
  docker-php-ext-configure gd --with-freetype-dir=/usr/lib/ --with-jpeg-dir=/usr/lib/ --with-png-dir=/usr/lib/ --with-webp-dir=/usr/lib/ --with-xpm-dir=/usr/lib/ ; \
  fi; \
  docker-php-ext-install gd \
  ;fi

#Install BZ2:
ARG INSTALL_BZ2=true
RUN if [ ${INSTALL_BZ2} = true ]; then \
  apk add --no-cache --update --no-progress bzip2-dev; \
  docker-php-ext-install bz2; \
  fi

###########################################################################
# Enchant:
###########################################################################

ARG INSTALL_ENCHANT=false
RUN if [ ${INSTALL_ENCHANT} = true ]; then \
  apk add --no-cache --update --no-progress enchant2-dev; \
  docker-php-ext-install enchant; \
  php -m | grep -oiE '^enchant$'; \
fi

###########################################################################
# GMP (GNU Multiple Precision):
###########################################################################

#Install GMP package:
ARG INSTALL_GMP=false
RUN if [ ${INSTALL_GMP} = true ]; then \
  apk add --no-cache --update --no-progress gmp gmp-dev && \
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
    ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
  ;fi && \
  docker-php-ext-install gmp \
  ;fi

###########################################################################
# PHP GnuPG:
###########################################################################

ARG INSTALL_GNUPG=false
RUN set -eux; if [ ${INSTALL_GNUPG} = true ]; then \
  apk add --no-cache --update --no-progress --virtual BUILD_DEPS_PHP_GNUPG gpgme-dev; \
  apk add --no-cache --update --no-progress gpgme; \
  pecl install gnupg; \
  docker-php-ext-enable gnupg; \
  fi

###########################################################################
# SOAP:
###########################################################################

#Install SOAP package:
ARG INSTALL_SOAP=false
RUN if [ ${INSTALL_SOAP} = true ]; then \
  docker-php-ext-install soap \
  ;fi

###########################################################################
# XSL:
###########################################################################

ARG INSTALL_XSL=false
RUN if [ ${INSTALL_XSL} = true ]; then \
    # Install the xsl extension
    apk add --no-cache --update --no-progress libxslt-dev && \
    docker-php-ext-install xsl \
;fi

###########################################################################
# pgsql
###########################################################################

# Install PostgreSQL drivers:
ARG INSTALL_PGSQL=true
RUN if [ ${INSTALL_PGSQL} = true ]; then \
  apk add --no-cache --update --no-progress postgresql-dev \
  && docker-php-ext-install pdo_pgsql \
  ;fi

###########################################################################
# PHP REDIS EXTENSION
###########################################################################

# Install Redis package:
ARG INSTALL_REDIS=true
RUN if [ ${INSTALL_REDIS} = true ]; then \
  # Install Redis Extension
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
  printf "\n" | pecl install -o -f redis-4.3.0; \
  else \
  printf "\n" | pecl install -o -f redis; \
  fi; \
  rm -rf /tmp/pear; \
  docker-php-ext-enable redis \
  ;fi

###########################################################################
# Swoole EXTENSION
###########################################################################

ARG INSTALL_SWOOLE=false
RUN set -eux; \
    if [ ${INSTALL_SWOOLE} = true ]; then \
      # Install Php Swoole Extension
      if   [ $(php -r "echo PHP_VERSION_ID - PHP_RELEASE_VERSION;") = "50600" ]; then \
        pecl install swoole-2.0.10; \
      elif [ $(php -r "echo PHP_VERSION_ID - PHP_RELEASE_VERSION;") = "70000" ]; then \
        pecl install swoole-4.3.5; \
      elif [ $(php -r "echo PHP_VERSION_ID - PHP_RELEASE_VERSION;") = "70100" ]; then \
        pecl install swoole-4.5.11; \
      elif [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ]; then \
        pecl install swoole-4.8.12; \
      else \
        pecl install swoole; \
      fi; \
      docker-php-ext-enable swoole; \
      php -m | grep -q 'swoole'; \
    fi

###########################################################################
# Taint EXTENSION
###########################################################################

ARG INSTALL_TAINT=false

RUN if [ ${INSTALL_TAINT} = true ]; then \
    # Install Php TAINT Extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ]; then \
      pecl install taint && \
      docker-php-ext-enable taint && \
      php -m | grep -q 'taint'; \
    fi \
;fi

###########################################################################
# MongoDB:
###########################################################################

ARG INSTALL_MONGO=false

RUN if [ ${INSTALL_MONGO} = true ]; then \
    # Install the mongodb extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      pecl install mongo; \
      docker-php-ext-enable mongo; \
      php -m | grep -oiE '^mongo$'; \
    else \
      if [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ] && { [ $(php -r "echo PHP_MINOR_VERSION;") = "0" ] || [ $(php -r "echo PHP_MINOR_VERSION;") = "1" ] ;}; then \
        pecl install mongodb-1.9.2; \
      else \
        pecl install mongodb; \
      fi; \
      docker-php-ext-enable mongodb; \
      php -m | grep -oiE '^mongodb$'; \
    fi; \
fi

###########################################################################
# AMQP:
###########################################################################

ARG INSTALL_AMQP=false

RUN set -eux; if [ ${INSTALL_AMQP} = true ]; then \
  apk add --no-cache --update --no-progress -q rabbitmq-c rabbitmq-c-dev && \
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
    printf "\n" | pecl install amqp-1.11.0; \
  else \
    printf "\n" | pecl install amqp; \
  fi; \
    docker-php-ext-enable amqp; \
    php -m | grep -oiE '^amqp$'; \
  fi

###########################################################################
# CASSANDRA:
###########################################################################

ARG INSTALL_CASSANDRA=false
RUN if [ ${INSTALL_CASSANDRA} = true ]; then \
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
  echo "PHP Driver for Cassandra is not supported for PHP 8.0."; \
  else \
  apk add --no-cache --update --no-progress cassandra-cpp-driver libuv gmp \
  && apk add --no-cache --update --no-progress cassandra-cpp-driver-dev gmp-dev --virtual .build-sec \
  && cd /usr/src \
  && git clone https://github.com/datastax/php-driver.git \
  && cd php-driver/ext \
  && phpize \
  && mkdir -p /usr/src/php-driver/build \
  && cd /usr/src/php-driver/build \
  && ../ext/configure > /dev/null \
  && make clean > /dev/null \
  && make > /dev/null 2>&1 \
  && make install \
  && docker-php-ext-enable cassandra \
  && apk del .build-sec; \
  fi \
  ;fi

###########################################################################
# xlswriter:
###########################################################################

ARG INSTALL_XLSWRITER=false

RUN set -eux; \
    if [ ${INSTALL_XLSWRITER} = true ]; then \
      # Install Php xlswriter Extension \
      if   [ $(php -r "echo PHP_MAJOR_VERSION;") != "5" ]; then \
          pecl install xlswriter && \
          docker-php-ext-enable xlswriter && \
          php -m | grep -q 'xlswriter'; \
      else \
          echo "PHP Extension for xlswriter is not supported for PHP 5.0"; \
      fi \
    ;fi

###########################################################################
# pcntl
###########################################################################

ARG INSTALL_PCNTL=true
RUN if [ ${INSTALL_PCNTL} = true ]; then \
    # Installs pcntl, helpful for running Horizon
    docker-php-ext-install pcntl \
;fi

###########################################################################
# bcmath:
###########################################################################

ARG INSTALL_BCMATH=true
RUN if [ ${INSTALL_BCMATH} = true ]; then \
  docker-php-ext-install bcmath \
  ;fi

###########################################################################
# PHP Memcached:
###########################################################################

ARG INSTALL_MEMCACHED=false

RUN if [ ${INSTALL_MEMCACHED} = true ]; then \
  apk add --no-cache --update --no-progress libmemcached-dev; \
  # Install the php memcached extension
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
  pecl install memcached-2.2.0; \
  else \
  pecl install memcached; \
  fi; \
  docker-php-ext-enable memcached; \
  php -m | grep -r 'memcached'; \
  fi

###########################################################################
# Exif:
###########################################################################

ARG INSTALL_EXIF=true
RUN if [ ${INSTALL_EXIF} = true ]; then \
    # Enable Exif PHP extentions requirements
    docker-php-ext-install exif \
;fi

###########################################################################
# IonCube Loader:
###########################################################################

ARG INSTALL_IONCUBE=false
RUN if [ ${INSTALL_IONCUBE} = true ]; then \
    if [ ${LNMP_PHP_VERSION} = "8.2" ] \
      || [ ${LNMP_PHP_VERSION} = "8.1" ] \
      || [ ${LNMP_PHP_VERSION} = "7.4" ] \
      || [ ${LNMP_PHP_VERSION} = "7.3" ] \
      || [ ${LNMP_PHP_VERSION} = "7.2" ] \
      || [ ${LNMP_PHP_VERSION} = "7.1" ] \
      || [ ${LNMP_PHP_VERSION} = "7.0" ] \
      || [ ${LNMP_PHP_VERSION} = "5.6" ]; then \
      # Install the php ioncube loader
      curl -L -o /tmp/ioncube_loaders_lin_x86-64.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
      && tar zxpf /tmp/ioncube_loaders_lin_x86-64.tar.gz -C /tmp \
      && ls -al /tmp/ioncube/ \
      && mv /tmp/ioncube/ioncube_loader_lin_${LNMP_PHP_VERSION}.so $(php -r "echo ini_get('extension_dir');")/ioncube_loader.so \
      && printf "zend_extension=ioncube_loader.so\n" > $PHP_INI_DIR/conf.d/0ioncube.ini \
      && rm -rf /tmp/ioncube* \
      && php -m | grep -oiE '^ionCube Loader$' \
    ;fi \
;fi

###########################################################################
# Opcache:
###########################################################################
ARG INSTALL_OPCACHE=true
RUN if [ ${INSTALL_OPCACHE} = true ]; then \
    docker-php-ext-install opcache \
;fi

# Copy opcache configration
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

###########################################################################
# Mysqli Modifications:
###########################################################################

ARG INSTALL_MYSQLI=true
RUN if [ ${INSTALL_MYSQLI} = true ]; then \
    docker-php-ext-install mysqli \
;fi

###########################################################################
# Human Language and Character Encoding Support:
###########################################################################

ARG INSTALL_INTL=false
RUN if [ ${INSTALL_INTL} = true ]; then \
    # Install intl and requirements
    apk add --no-cache --update --no-progress zlib-dev icu-dev g++ && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl \
;fi

###########################################################################
# LDAP:
###########################################################################
ARG INSTALL_LDAP=false
RUN set -eux; if [ ${INSTALL_LDAP} = true ]; then \
  apk add --no-cache --update --no-progress openldap-dev; \
  docker-php-ext-install ldap; \
  php -m | grep -oiE '^ldap$'; \
  fi

###########################################################################
# ImageMagick:
###########################################################################

ARG INSTALL_IMAGEMAGICK=true
ARG IMAGEMAGICK_VERSION=latest
ENV IMAGEMAGICK_VERSION ${IMAGEMAGICK_VERSION}
RUN set -eux; \
  if [ ${INSTALL_IMAGEMAGICK} = true ]; then \
  apk add --no-cache --update --no-progress imagemagick-dev imagemagick; \
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
  php -m | grep -q 'imagick'; \
  fi

###########################################################################
# Imap EXTENSION
###########################################################################

ARG INSTALL_IMAP=false

RUN if [ ${INSTALL_IMAP} = true ]; then \
  apk add --no-cache --update --no-progress imap-dev && \
  docker-php-ext-configure imap --with-imap --with-imap-ssl && \
  docker-php-ext-install imap \
  ;fi

###########################################################################
# Phalcon:
###########################################################################

ARG INSTALL_PHALCON=false
ARG PHALCON_VERSION
ENV PHALCON_VERSION ${PHALCON_VERSION}

RUN if [ $INSTALL_PHALCON = true ]; then \
      pecl channel-update pecl.php.net; \
      apk add --no-cache --update --no-progress pcre-dev; \
      pecl install phalcon-${PHALCON_VERSION}; \
      docker-php-ext-enable phalcon; \
      php -m | grep -q 'phalcon' \
    ;fi

###########################################################################
# XMLRPC:
###########################################################################

ARG INSTALL_XMLRPC=false

RUN if [ ${INSTALL_XMLRPC} = true ]; then \
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
  pecl install xmlrpc-1.0.0RC3; \
  docker-php-ext-enable xmlrpc; \
  else \
  docker-php-ext-install xmlrpc; \
  fi; \
  php -m | grep -r 'xmlrpc'; \
  fi

###########################################################################
# PHP SSDB:
###########################################################################

USER root

ARG INSTALL_SSDB=false

RUN set -xe; \
  if [ ${INSTALL_SSDB} = true ] && [ $(php -r "echo PHP_MAJOR_VERSION;") != "8" ]; then \
  apk add --no-cache --update --no-progress sudo wget && \
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ]; then \
  curl -L -o /tmp/ssdb-client-php.tar.gz https://github.com/jonnywang/phpssdb/archive/php7.tar.gz; \
  else \
  curl -L -o /tmp/ssdb-client-php.tar.gz https://github.com/jonnywang/phpssdb/archive/master.tar.gz; \
  fi \
  && mkdir -p /tmp/ssdb-client-php \
  && tar -C /tmp/ssdb-client-php -zxvf /tmp/ssdb-client-php.tar.gz --strip 1 \
  && cd /tmp/ssdb-client-php \
  && phpize \
  && ./configure \
  && make \
  && make install \
  && rm /tmp/ssdb-client-php.tar.gz \
  && docker-php-ext-enable ssdb \
  ;fi

############################################################################
## Event:
############################################################################
USER root

ARG INSTALL_EVENT=true
RUN set -eux; \
  if [ ${INSTALL_EVENT} = true ]; then \
      apk add --no-cache --update --no-progress python3 && \
      curl -L -o  /tmp/libevent.tar.gz https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz   &&\
      mkdir -p /tmp/libevent-php &&\
      tar -C /tmp/libevent-php -zxvf /tmp/libevent.tar.gz --strip 1 &&\
      cd /tmp/libevent-php &&\
      ./configure --prefix=/usr/local/libevent-2.1.12  &&\
      make &&\
      make install &&\
      rm /tmp/libevent.tar.gz &&\
      docker-php-ext-install sockets  &&\
      curl -L -o /tmp/event.tar.gz http://pecl.php.net/get/event-3.0.6.tgz &&\
      mkdir -p /tmp/event-php &&\
      tar -C /tmp/event-php -zxvf /tmp/event.tar.gz --strip 1 &&\
      cd /tmp/event-php &&\
      phpize &&\
      ./configure  --with-event-libevent-dir=/usr/local/libevent-2.1.12/ &&\
      make &&\
      make install &&\
      rm /tmp/event.tar.gz &&\
      docker-php-ext-enable event &&\
      mv /usr/local/etc/php/conf.d/docker-php-ext-event.ini /usr/local/etc/php/conf.d/docker-php-ext-z-event.ini &&\
      php -m  | grep -q 'event' &&\
      apk del python3 \
;fi

# Install ZipArchive:
ARG INSTALL_ZIP_ARCHIVE=true
RUN set -eux; \
  if [ ${INSTALL_ZIP_ARCHIVE} = true ]; then \
  apk add --no-cache --update --no-progress libzip-dev && \
  if [ ${LNMP_PHP_VERSION} = "7.3" ] || [ ${LNMP_PHP_VERSION} = "7.4" ] || [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
  docker-php-ext-configure zip; \
  else \
  docker-php-ext-configure zip --with-libzip; \
  fi && \
  # Install the zip extension
  docker-php-ext-install zip \
  ;fi

# Install MySQL Client:
ARG INSTALL_MYSQL_CLIENT=false
RUN if [ ${INSTALL_MYSQL_CLIENT} = true ]; then \
  apk add --no-cache --update --no-progress mysql-client \
  ;fi

# Install FFMPEG:
ARG INSTALL_FFMPEG=false
RUN if [ ${INSTALL_FFMPEG} = true ]; then \
  apk add --no-cache --update --no-progress ffmpeg \
  ;fi

###########################################################################
# Check PHP version:
###########################################################################

RUN set -xe; php -v | head -n 1 | grep -q "PHP ${LNMP_PHP_VERSION}."

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

COPY ./php.ini /usr/local/etc/php/conf.d
COPY ./xphp.pool.conf /usr/local/etc/php-fpm.d/

# Configure locale.
ARG LOCALE=POSIX
ENV LC_ALL ${LOCALE}

ARG APP_CODE_PATH_CONTAINER=/var/www

# Clean up
RUN rm -rf /tmp/* \
  && rm -rf /var/cache/apk/* \
  && mkdir -p ${APP_CODE_PATH_CONTAINER}

WORKDIR ${APP_CODE_PATH_CONTAINER}

CMD ["php-fpm"]

EXPOSE 9000