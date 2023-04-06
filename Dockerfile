ARG ALPINE_VERSION
ARG PYTHON_VERSION

FROM python:${PYTHON_VERSION}
ARG SUPYSONIC_VERSION
COPY .circleci /supysonic/build
ADD https://github.com/spl0k/supysonic/archive/${SUPYSONIC_VERSION}.tar.gz \
  /supysonic/src/supysonic.tar.gz
ARG CONTAINER_TAG
ENV CONTAINER_TAG=${CONTAINER_TAG}
RUN /supysonic/build/build.sh

FROM alpine:${ALPINE_VERSION}
ARG EXTRA_PACKAGES
COPY --from=0 /supysonic/pkg /
RUN apk add expat libffi libjpeg-turbo sqlite-libs ${EXTRA_PACKAGES} && \
  chown supysonic:users /var/lib/supysonic /var/log/supysonic && \
  rm -rf /root/.ash_history /root/.cache /var/cache/apk/*
ENV \
  SUPYSONIC_DB_URI="sqlite:////var/lib/supysonic/supysonic.db" \
  SUPYSONIC_SCANNER_EXTENSIONS="" \
  SUPYSONIC_SECRET_KEY="" \
  SUPYSONIC_WEBAPP_CACHE_DIR="/var/lib/supysonic/cache" \
  SUPYSONIC_WEBAPP_LOG_FILE="/var/log/supysonic/supysonic.log" \
  SUPYSONIC_WEBAPP_LOG_LEVEL="WARNING" \
  SUPYSONIC_DAEMON_ENABLED="false" \
  SUPYSONIC_DAEMON_SOCKET="/var/lib/supysonic/supysonic-daemon.sock" \
  SUPYSONIC_DAEMON_LOG_FILE="/var/log/supysonic/supysonic-daemon.log" \
  SUPYSONIC_DAEMON_LOG_LEVEL="INFO" \
  SUPYSONIC_LASTFM_API_KEY="" \
  SUPYSONIC_LASTFM_SECRET="" \
  SUPYSONIC_FCGI_PORT="5000" \
  SUPYSONIC_FCGI_SOCKET="/var/lib/supysonic/supysonic.sock" \
  SUPYSONIC_RUN_MODE="fcgi"
EXPOSE 5000
VOLUME [ "/var/lib/supysonic", "/var/log/supysonic", "/media" ]
USER supysonic
ENTRYPOINT [ "/entrypoint.sh" ]
