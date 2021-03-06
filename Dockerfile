#
# Dockerfile for v2ray with WebSocket
#

FROM golang:alpine as builder

RUN apk update && apk add --no-cache git bash wget curl
WORKDIR /go/src/v2ray.com/core
RUN git clone --progress https://github.com/v2fly/v2ray-core.git . && \
    bash ./release/user-package.sh nosource noconf codename=$(git describe --tags) buildname=docker-fly abpathtgz=/tmp/v2ray.tgz

FROM alpine:latest

COPY --from=builder /tmp/v2ray.tgz /tmp

RUN set -ex && \
    apk --no-cache add ca-certificates && \
    mkdir /var/log/v2ray/ &&\
    mkdir -p /usr/bin/v2ray && \
    tar xvfz /tmp/v2ray.tgz -C /usr/bin/v2ray && \
    rm -rf /var/cache/apk

COPY config.json /etc/v2ray/config.json
COPY docker-entrypoint.sh /entrypoint.sh

ENV PATH /usr/bin/v2ray:$PATH
ENV PORT 80
ENV UUID 00000000-0000-0000-0000-000000000000
ENV ALTERID 2
ENV WSPATH /css

EXPOSE $PORT/tcp

WORKDIR /etc/v2ray

ENTRYPOINT ["/entrypoint.sh"]

CMD ["v2ray", "-config=/etc/v2ray/config.json"]
