# openzwave2mqtt, ozwdaemon

# docker build . -t openzwave2mqtt
# docker run --privileged  -ti --rm -e TZ=Europe/Amsterdam -v /dev/ttyUSB0:/dev/ttyUSB0 -v $(pwd)/config:/config -e MQTT_SERVER="10.100.200.102" -e MQTT_USER=ozw -e MQTT_PASS="pass" openzwave2mqtt

ARG ARCH=arm
ARG VERSION=build-98

FROM "openzwave/ozwdaemon:${VERSION}" as openzwave2mqtt

ARG ARCH
ARG VERSION
ARG MYVERSION=jose0
ARG TZ=Europe/Amsterdam
ARG CONFIGDIR=/config

LABEL org.label-schema.description="OpenZwave to MQTT bridge, ozwdaemon"
LABEL org.label-schema.name="rpi-openzwave2mqtt"
LABEL org.label-schema.version="${VERSION}-${MYVERSION}"
LABEL org.label-schema.usage="/README.md"
LABEL org.label-schema.url="https://hub.docker.com/r/jriguera/rpi-openzwave2mqtt"
LABEL org.label-schema.vcs-url="https://github.com/jriguera/docker-rpi-openzwave2mqtt"
LABEL maintainer="Jose Riguera <jriguera@gmail.com>"
LABEL architecture="${ARCH}"

ENV LANG=en_US.utf8
ENV LC_ALL=C.UTF-8
ENV CONFIGDIR="${CONFIGDIR}"

RUN set -xe                                                                 && \
    apt-get update                                                          && \
    apt-get install --no-install-recommends -qq -y \
        tzdata \
        bash \
        curl \
        jq \
        ca-certificates \
        pwgen \
                                                                            && \
    # Timezone
    cp "/usr/share/zoneinfo/${TZ}" /etc/localtime                           && \
    echo "${TZ}" > /etc/timezone                                            && \
    ln -s /lib /lib64                                                       && \
    # clean up
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* /var/cache/distfiles/* ~/.cache

COPY *.sh /usr/local/bin/

RUN set -xe                                                                    && \
    chmod a+x /usr/local/bin/*                                                 && \
    rm -f /usr/local/bin/docker-entrypoint.sh                                  && \
    ln -s /usr/local/bin/openzwave2mqtt.sh /usr/local/bin/docker-entrypoint.sh && \
    ln -s /usr/local/bin/openzwave2mqtt.sh /docker-entrypoint.sh               && \
    ln -s /usr/local/bin/openzwave2mqtt.sh /run.sh                             && \
    mkdir -p /docker-entrypoint-initdb.d                                       && \
    mkdir -p "${CONFIGDIR}"

WORKDIR "${CONFIGDIR}"
VOLUME "${CONFIGDIR}"
ENTRYPOINT ["/run.sh"]
CMD ["ozwdaemon"]

