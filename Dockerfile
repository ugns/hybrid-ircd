FROM alpine:latest AS builder

WORKDIR /build

ARG HYBRID_VERSION=8.2.24

RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates libgcc libstdc++ libssl1.0 libcrypto1.0 file \
    gcc libc-dev openssl-dev make curl && \
    curl -sL https://github.com/ircd-hybrid/ircd-hybrid/archive/${HYBRID_VERSION}.tar.gz |tar xzf - && \
    cd ircd-hybrid-* && \
    ./configure --prefix /ircd && \
    make && \
    make install


FROM alpine:latest

MAINTAINER Jeremy T. Bouse <Jeremy.Bouse@UnderGrid.net>

WORKDIR /ircd

RUN adduser -D ircd -s /bin/false ircd && \
    apk upgrade --no-cache && \
    apk add --no-cache ca-certificates libgcc libstdc++ libssl1.0 libcrypto1.0 file

COPY --from=builder --chown=1000 /ircd /ircd

USER ircd

EXPOSE 6665 6666 6667 6668 6669

CMD ["/ircd/bin/ircd", "-foreground"]
