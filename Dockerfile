FROM alpine:latest AS builder

WORKDIR /build

ARG HYBRID_VERSION=8.2.24

RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates file gcc libc-dev gnutls-dev make curl && \
    curl -sL https://github.com/ircd-hybrid/ircd-hybrid/archive/${HYBRID_VERSION}.tar.gz |tar xzf - && \
    cd ircd-hybrid-${HYBRID_VERSION} && \
    ./configure --prefix /ircd && \
    make && \
    make install


FROM alpine:latest

LABEL maintainer="Jeremy.Bouse@UnderGrid.net"

WORKDIR /ircd

RUN adduser -D ircd -s /bin/false ircd && \
    apk upgrade --no-cache && \
    apk add --no-cache ca-certificates gnutls-utils tini

COPY --from=builder --chown=1000 /ircd /ircd

USER ircd

EXPOSE 6667

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/ircd/bin/ircd", "-foreground"]
