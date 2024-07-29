ARG POSTGRES_VERSION=16-3.4-alpine
FROM postgis/postgis:${POSTGRES_VERSION}

# 修改源并更新包
RUN sed -i -e 's/http:/https:/g' /etc/apk/repositories && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && apk update && apk upgrade

CMD ["postgres"]

EXPOSE 5432
