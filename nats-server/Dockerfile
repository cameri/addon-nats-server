ARG BUILD_FROM=ghcr.io/hassio-addons/base/aarch64:15.0.8

FROM ${BUILD_FROM}

ARG NATS_SERVER_VERSION

RUN set -eux; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		aarch64) natsArch='arm64'; sha256='57aa4464759d211df247b645dae6d0c0724d84aa2db3dc042cd2dc9fe8553302' ;; \
		armhf) natsArch='arm6'; sha256='125dba652ee7c4c60bf1af3ced1c590e7d32f7624e27364c278069da660f04ea' ;; \
		armv7) natsArch='arm7'; sha256='1215a787ac52d03bc2c43069ac4229b891be7dafeb2ea44f58dc5c854001629c' ;; \
		x86_64) natsArch='amd64'; sha256='8e1ba988220e7f3a0156c085b7c4fe47222ee8342cf1cfa7b364e30d9d6aa47d' ;; \
		x86) natsArch='386'; sha256='29b361db7d0ece5ba74ac6aa1911446573db3a4806c175df4bd37142bccf5e06' ;; \
		s390x) natsArch='s390x'; sha256='f9a3c2b1ca2d89bc865b08d37451e5c1949112e042c69fdb88bbb6938ad774a8' ;; \
		ppc64le) natsArch='ppc64le'; sha256='276f4f5d080a96c31c4e1a15e84aafefef5d82dd93c112ea659f17f068ab4b6a' ;; \
		*) echo >&2 "error: $apkArch is not supported!"; exit 1 ;; \
	esac; \
	\
	wget -O nats-server.tar.gz "https://github.com/nats-io/nats-server/releases/download/v${NATS_SERVER_VERSION}/nats-server-v${NATS_SERVER_VERSION}-linux-${natsArch}.tar.gz"; \
	echo "${sha256} *nats-server.tar.gz" | sha256sum -c -; \
	\
	apk add --no-cache ca-certificates tzdata gettext; \
	\
	tar -xf nats-server.tar.gz; \
	rm nats-server.tar.gz; \
	mv "nats-server-v${NATS_SERVER_VERSION}-linux-${natsArch}/nats-server" /usr/local/bin; \
	rm -rf "nats-server-v${NATS_SERVER_VERSION}-linux-${natsArch}";

COPY run.sh /usr/local/bin
RUN mkdir -p /etc/nats

EXPOSE 4222 8222 6222 1883
ENTRYPOINT ["run.sh"]
CMD ["nats-server", "--config", "/etc/nats/nats-server.conf"]