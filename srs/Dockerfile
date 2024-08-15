ARG SRS_VERSION=6
FROM ossrs/srs:${SRS_VERSION}

COPY srs.conf /usr/local/srs/conf/

WORKDIR /usr/local/srs

CMD ["./objs/srs" "-c" "conf/srs.conf"]
