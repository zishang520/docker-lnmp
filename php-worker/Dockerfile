ARG LNMP_PHP_VERSION
FROM php:${LNMP_PHP_VERSION}-alpine
MAINTAINER None

# Change application source from dl-cdn.alpinelinux.org to aliyun source
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && apk update && apk upgrade

RUN apk --update add wget \
  curl \
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
  libressl \
  libressl-dev \
  supervisor

RUN set -eux; \
  pecl channel-update pecl.php.net; \
  docker-php-ext-install mysqli mbstring pdo pdo_mysql tokenizer xml pcntl

#Install BZ2:
ARG INSTALL_BZ2=false
RUN apk --update add bzip2-dev && docker-php-ext-install bz2

###########################################################################
# PHP GnuPG:
###########################################################################

RUN set -eux; \
  apk add --no-cache --no-progress --virtual BUILD_DEPS_PHP_GNUPG gpgme-dev; \
  apk add --no-cache --no-progress gpgme; \
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
  pecl install gnupg-1.5.0RC2; \
  else \
  pecl install gnupg; \
  fi; \
  docker-php-ext-enable gnupg;

#Install LDAP
RUN set -eux; \
  apk add --no-cache --no-progress openldap-dev; \
  docker-php-ext-install ldap; \
  php -m | grep -oiE '^ldap$';

#Install GD package:
RUN set -eux; \
  apk add --update --no-cache freetype-dev libjpeg-turbo-dev jpeg-dev libpng-dev; \
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ] && [ $(php -r "echo PHP_MINOR_VERSION;") = "4" ]; then \
  docker-php-ext-configure gd --with-freetype --with-jpeg --with-png; \
  else \
  docker-php-ext-configure gd --with-freetype-dir=/usr/lib/ --with-jpeg-dir=/usr/lib/ --with-png-dir=/usr/lib/; \
  fi; \
  docker-php-ext-install gd;

#Install ImageMagick:
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
  php -m | grep -q 'imagick';

#Install GMP package:
RUN apk add --update --no-cache gmp gmp-dev \
  && docker-php-ext-install gmp

#Install BCMath package:
RUN docker-php-ext-install bcmath

#Install SOAP package:
RUN docker-php-ext-install soap

# Install MongoDB drivers:
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

###########################################################################
# PHP OCI8:
###########################################################################

ARG INSTALL_OCI8=false

ENV LD_LIBRARY_PATH="/usr/local/instantclient"
ENV ORACLE_HOME="/usr/local/instantclient"

RUN if [ ${INSTALL_OCI8} = true ] && [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ]; then \
  apk add make php7-pear php7-dev gcc musl-dev libnsl libaio poppler-utils libzip-dev zip unzip libaio-dev freetds-dev && \
  ## Download and unarchive Instant Client v11
  curl -o /tmp/basic.zip https://raw.githubusercontent.com/bumpx/oracle-instantclient/master/instantclient-basic-linux.x64-11.2.0.4.0.zip && \
  curl -o /tmp/sdk.zip https://raw.githubusercontent.com/bumpx/oracle-instantclient/master/instantclient-sdk-linux.x64-11.2.0.4.0.zip && \
  curl -o /tmp/sqlplus.zip https://raw.githubusercontent.com/bumpx/oracle-instantclient/master/instantclient-sqlplus-linux.x64-11.2.0.4.0.zip && \
  unzip -d /usr/local/ /tmp/basic.zip && \
  unzip -d /usr/local/ /tmp/sdk.zip && \
  unzip -d /usr/local/ /tmp/sqlplus.zip \
  ## Links are required for older SDKs
  && ln -s /usr/local/instantclient_11_2 ${ORACLE_HOME} && \
  ln -s ${ORACLE_HOME}/libclntsh.so.* ${ORACLE_HOME}/libclntsh.so && \
  ln -s ${ORACLE_HOME}/libocci.so.* ${ORACLE_HOME}/libocci.so && \
  ln -s ${ORACLE_HOME}/lib* /usr/lib && \
  ln -s ${ORACLE_HOME}/sqlplus /usr/bin/sqlplus &&\
  ln -s /usr/lib/libnsl.so.2.0.0  /usr/lib/libnsl.so.1 && \
  ## Build OCI8 with PECL
  echo "instantclient,${ORACLE_HOME}" | pecl install oci8 && \
  echo 'extension=oci8.so' > /etc/php7/conf.d/30-oci8.ini \
  #  Clean up
  apk del php7-pear php7-dev gcc musl-dev && \
  rm -rf /tmp/*.zip /tmp/pear/ && \
  docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/local/instantclient \
  && docker-php-ext-configure pdo_dblib --with-libdir=/lib \
  && docker-php-ext-install pdo_oci \
  && docker-php-ext-enable oci8 \
  && docker-php-ext-install zip && \
  # Install the zip extension
  docker-php-ext-configure zip && \
  php -m | grep -q 'zip' \
  ;fi

# Install PostgreSQL drivers:
RUN apk --update add postgresql-dev \
  && docker-php-ext-install pdo_pgsql

# Install ZipArchive:
RUN set -eux; \
  apk --update add libzip-dev && \
  if [ ${LNMP_PHP_VERSION} = "7.3" ] || [ ${LNMP_PHP_VERSION} = "7.4" ] || [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
  docker-php-ext-configure zip; \
  else \
  docker-php-ext-configure zip --with-libzip; \
  fi && \
  # Install the zip extension
  docker-php-ext-install zip

# Install MySQL Client:
RUN apk --update add mysql-client

# Install FFMPEG:
ARG INSTALL_FFMPEG=false
RUN if [ ${INSTALL_FFMPEG} = true ]; then \
  apk --update add ffmpeg \
  ;fi

# Install BBC Audio Waveform Image Generator:
ARG INSTALL_AUDIOWAVEFORM=false
RUN if [ ${INSTALL_AUDIOWAVEFORM} = true ]; then \
  apk add git make cmake gcc g++ libmad-dev libid3tag-dev libsndfile-dev gd-dev boost-dev libgd libpng-dev zlib-dev \
  && apk add autoconf automake libtool gettext \
  && wget https://github.com/xiph/flac/archive/1.3.3.tar.gz \
  && tar xzf 1.3.3.tar.gz \
  && cd flac-1.3.3 \
  && ./autogen.sh \
  && ./configure --enable-shared=no \
  && make \
  && make install \
  && cd .. \
  && git clone https://github.com/bbc/audiowaveform.git \
  && cd audiowaveform \
  && wget https://github.com/google/googletest/archive/release-1.10.0.tar.gz \
  && tar xzf release-1.10.0.tar.gz \
  && ln -s googletest-release-1.10.0/googletest googletest \
  && ln -s googletest-release-1.10.0/googlemock googlemock \
  && mkdir build \
  && cd build \
  && cmake .. \
  && make \
  && make install \
  ;fi

# Install AMQP:
ARG INSTALL_AMQP=false

RUN if [ ${INSTALL_AMQP} = true ]; then \
  apk --update add -q rabbitmq-c rabbitmq-c-dev && \
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
  printf "\n" | pecl install amqp-1.11.0beta; \
  else \
  printf "\n" | pecl install amqp; \
  fi && \
  docker-php-ext-enable amqp && \
  apk del -q rabbitmq-c-dev && \
  docker-php-ext-install sockets \
  ;fi

# Install Gearman:
ARG INSTALL_GEARMAN=false

RUN if [ ${INSTALL_GEARMAN} = true ]; then \
  sed -i "\$ahttp://dl-cdn.alpinelinux.org/alpine/edge/main" /etc/apk/repositories && \
  sed -i "\$ahttp://dl-cdn.alpinelinux.org/alpine/edge/community" /etc/apk/repositories && \
  sed -i "\$ahttp://dl-cdn.alpinelinux.org/alpine/edge/testing" /etc/apk/repositories && \
  apk --update add php7-gearman && \
  sh -c 'echo "extension=/usr/lib/php7/modules/gearman.so" > /usr/local/etc/php/conf.d/gearman.ini' \
  ;fi

# Install Cassandra drivers:
ARG INSTALL_CASSANDRA=false
RUN if [ ${INSTALL_CASSANDRA} = true ]; then \
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
  echo "PHP Driver for Cassandra is not supported for PHP 8.0."; \
  else \
  apk add --update --no-cache cassandra-cpp-driver libuv gmp \
  && apk add --update --no-cache cassandra-cpp-driver-dev gmp-dev --virtual .build-sec \
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

# Install Phalcon ext
ARG INSTALL_PHALCON=false
ARG PHALCON_VERSION
ENV PHALCON_VERSION ${PHALCON_VERSION}

RUN if [ $INSTALL_PHALCON = true ]; then \
  apk --update add unzip gcc make re2c bash\
  && git clone https://github.com/jbboehr/php-psr.git \
  && cd php-psr \
  && phpize \
  && ./configure \
  && make \
  && make test \
  && make install \
  && curl -L -o /tmp/cphalcon.zip https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.zip \
  && unzip -d /tmp/ /tmp/cphalcon.zip \
  && cd /tmp/cphalcon-${PHALCON_VERSION}/build \
  && ./install \
  && rm -rf /tmp/cphalcon* \
  ;fi

ARG INSTALL_GHOSTSCRIPT=false
RUN if [ $INSTALL_GHOSTSCRIPT = true ]; then \
  apk --update add ghostscript \
  ;fi

# Install Redis package:
RUN if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
  printf "\n" | pecl install -o -f redis-4.3.0; \
  else \
  printf "\n" | pecl install -o -f redis; \
  fi; \
  rm -rf /tmp/pear; \
  docker-php-ext-enable redis

# Install enchant package
RUN if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
  apk --update add php7-enchant && \
  sh -c 'echo "extension=/usr/lib/php7/modules/enchant.so" > /usr/local/etc/php/conf.d/enchant.ini' \
  else \
  apk add enchant2-dev; \
  docker-php-ext-install -j$(nproc) enchant; \
  ;fi

###########################################################################
# Swoole EXTENSION
###########################################################################

ARG INSTALL_SWOOLE=false

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

###########################################################################
# Taint EXTENSION
###########################################################################

ARG INSTALL_TAINT=false

RUN if [ ${INSTALL_TAINT} = true ]; then \
  # Install Php TAINT Extension
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ]; then \
  pecl install taint; \
  docker-php-ext-enable taint; \
  php -m | grep -q 'taint'; \
  else \
  echo 'taint not Support'; \
  fi \
  ;fi

###########################################################################
# Imap EXTENSION
###########################################################################

RUN apk add --update imap-dev && \
  docker-php-ext-configure imap --with-imap --with-imap-ssl && \
  docker-php-ext-install imap

###########################################################################
# XMLRPC:
###########################################################################

RUN if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
  pecl install xmlrpc-1.0.0RC2; \
  docker-php-ext-enable xmlrpc; \
  else \
  docker-php-ext-install xmlrpc; \
  fi; \
  php -m | grep -r 'xmlrpc'

###########################################################################
# PHP Memcached:
###########################################################################

RUN apk --update add libmemcached-dev; \
  # Install the php memcached extension
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
  pecl install memcached-2.2.0; \
  else \
  pecl install memcached; \
  fi; \
  docker-php-ext-enable memcached; \
  php -m | grep -r 'memcached'

###########################################################################
# SQL SERVER:
###########################################################################

ARG INSTALL_MSSQL=false

RUN set -eux; \
  if [ ${INSTALL_MSSQL} = true ]; then \
  apk add --update gnupg \
  ###########################################################################
  # Ref from:
  # - https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15#alpine17
  ###########################################################################
  # Add Microsoft repo for Microsoft ODBC Driver 17 for Linux
  # Driver version 17.5 or higher is required for Alpine support.
  # Download the desired package(s)
  && curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.8.1.1-1_amd64.apk \
  # Verify signature, if 'gpg' is missing install it using 'apk add gnupg':
  && curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.8.1.1-1_amd64.sig \
  && curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import - \
  && gpg --verify msodbcsql17_17.8.1.1-1_amd64.sig msodbcsql17_17.8.1.1-1_amd64.apk \
  # Install the package(s)
  && apk add --allow-untrusted msodbcsql17_17.8.1.1-1_amd64.apk unixodbc-dev \
  && pecl install sqlsrv pdo_sqlsrv \
  # && echo extension=pdo_sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/10_pdo_sqlsrv.ini
  # && echo extension=sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/00_sqlsrv.ini
  && docker-php-ext-enable pdo_sqlsrv sqlsrv \
  && php -m | grep -q 'pdo_sqlsrv' \
  && php -m | grep -q 'sqlsrv' \
  ;fi

###########################################################################
# PHP SSDB:
###########################################################################

USER root

ARG INSTALL_SSDB=false

RUN set -xe; \
  if [ ${INSTALL_SSDB} = true ] && [ $(php -r "echo PHP_MAJOR_VERSION;") != "8" ]; then \
  apk --update add sudo wget && \
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

#
#--------------------------------------------------------------------------
# Optional Supervisord Configuration
#--------------------------------------------------------------------------
#
# Modify the ./supervisor.conf file to match your App's requirements.
# Make sure you rebuild your container with every change.
#

COPY supervisord.conf /etc/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]

#
#--------------------------------------------------------------------------
# Optional Software's Installation
#--------------------------------------------------------------------------
#
# If you need to modify this image, feel free to do it right here.
#
# -- Your awesome modifications go here -- #

#
#--------------------------------------------------------------------------
# Check PHP version
#--------------------------------------------------------------------------
#

RUN php -v | head -n 1 | grep -q "PHP ${PHP_VERSION}."

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

# Clean up
ARG APP_CODE_PATH_CONTAINER=/var/www
RUN rm /var/cache/apk/* \
  && mkdir -p ${APP_CODE_PATH_CONTAINER}

WORKDIR /etc/supervisor/conf.d/
