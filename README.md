# Docker PHP Nginx Mysql MongoDB Redis

#### PHP
>镜像：`php:7.4-fpm-alpine`

-  扩展支持 enchant bcmath calendar exif gettext sockets dba mysqli pcntl pdo_mysql shmop sysvmsg sysvsem sysvshm bz2 gd gmp soap xmlrpc tidy xsl zip snmp pgsql pdo_pgsql pspell pdo_dblib ldap imap intl imagick memcached redis opcache swoole mongodb 扩展
-  **wwwroot** 目录为 `./nginx/www`
-  **logs** 目录为 `./php/logs`
-  **php-fpm.d** 目录为 `./php/php-fpm.d`
-  **容器内Mysql主机地址(host)**: `docker_mysql`
-  **容器内Redis主机地址(host)**: `docker_redis`
-  **容器内Mongo主机地址(host)**: `docker_mongo`

其它查阅`docker-compose.yml`文件**docker_php:**部分

#### Nginx
>镜像：`nginx:stable-alpine`

-  **wwwroot** 目录为 `./nginx/www`
-  **logs** 目录为 `./nginx/logs`
-  **conf** 目录为 `./nginx/conf`
-  **容器内PHP主机地址(host)**: `docker_php`

其它查阅`docker-compose.yml`文件**docker_nginx:**部分

#### Mysql
>镜像：`mysql:5.7.35`

-  **conf.d** 目录为 `./mysql/conf.d`
-  **logs** 目录为 `./mysql/logs`
-  **数据(data)** 目录为 `./mysql/data`
-  **编码(charset)** 为 `utf8mb4`
-  **排序规则(charset-collation)** 为 `utf8mb4_unicode_520_ci`
-  <span style="color:#a50">root 密码请在 docker-compose 之前请先为`.env`中环境变量`MYSQL_ROOT_PASSWORD`设定值，默认为`root`</span>

其它查阅`docker-compose.yml`文件**docker_mysql:**部分，<span style="color:#f56b7e">注意：数据库未开启外网访问权限，自己用ssh跳板吧</span>

#### Mongo
>镜像：`mongo:latest`

-  **数据(data)** 目录为 `./mongod/data`
-  <span style="color:#a50">root 用户名请在 docker-compose 之前请先为`.env`中环境变量`MONGO_INITDB_ROOT_USERNAME`设定值，默认为`root`</span>
-  <span style="color:#a50">root 用户密码请在 docker-compose 之前请先为`.env`中环境变量`MONGO_INITDB_ROOT_PASSWORD`设定值，默认为`root`</span>

其它查阅`docker-compose.yml`文件**docker_mongo:**部分，<span style="color:#f56b7e">注意：数据库未开启外网访问权限，自己用ssh跳板吧</span>

#### Redis
>镜像：`mongo:latest`

-  **数据(data)** 目录为 `./redis/data`
-  <span style="color:#a50">密码请在 docker-compose 之前请先为`.env`中环境变量`REDIS_PASSWORD`设定值，默认为`root`</span>

其它查阅`docker-compose.yml`文件**docker_redis:**部分，<span style="color:#f56b7e">注意：数据库未开启外网访问权限，自己用ssh跳板吧</span>