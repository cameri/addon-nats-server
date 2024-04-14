ARG BUILD_FROM=ghcr.io/hassio-addons/base/aarch64:15.0.8

# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Confiure locale
ENV \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG NATS_SERVER_VERSION

RUN set -eux; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		aarch64) natsArch='arm64'; sha256='57aa4464759d211df247b645dae6d0c0724d84aa2db3dc042cd2dc9fe8553302' ;; \
		armhf) natsArch='arm6'; sha256='125dba652ee7c4c60bf1af3ced1c590e7d32f7624e27364c278069da660f04ea' ;; \
		armv7) natsArch='arm7'; sha256='1215a787ac52d03bc2c43069ac4229b891be7dafeb2ea44f58dc5c854001629c' ;; \
		*) echo >&2 "error: $apkArch is not supported!"; exit 1 ;; \
	esac; \
	\
	wget -q -O nats-server.tar.gz "https://github.com/nats-io/nats-server/releases/download/v${NATS_SERVER_VERSION}/nats-server-v${NATS_SERVER_VERSION}-linux-${natsArch}.tar.gz"; \
	echo "${sha256} *nats-server.tar.gz" | sha256sum -c -; \
	\
	apk add --no-cache \
		ca-certificates=20240226-r0 \
		tzdata=2024a-r0 \
		gettext=0.22.3-r0; \
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
