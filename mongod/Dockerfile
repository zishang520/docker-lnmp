FROM mongo:latest
LABEL maintainer=None

#COPY mongo.conf /usr/local/etc/mongo/mongo.conf

VOLUME /data/db /data/configdb

CMD ["mongod", "--quiet"]

EXPOSE 27017

