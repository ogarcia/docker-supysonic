FROM python:3-alpine3.9

ADD https://github.com/spl0k/supysonic/archive/70f18b981ab16cbbe1e4ee20974747d55ce297bd.zip /supysonic.zip

RUN unzip supysonic.zip && rm supysonic.zip && mkdir /app && \
  apk -U --no-progress upgrade && \
  apk --no-progress add gcc musl-dev zlib-dev jpeg-dev libjpeg-turbo && \
  cd supysonic-* && pip install flup && python setup.py install && \
  mv /supysonic-*/cgi-bin/server.py /app && \
  mv /supysonic-*/config.sample /app && \
  cd / && rm -rf /supysonic-* && \
  apk --no-progress del gcc musl-dev zlib-dev jpeg-dev && \
  adduser -S -D -H -h /var/lib/supysonic -s /sbin/nologin -G users \
  -g supysonic supysonic && mkdir -p /var/lib/supysonic && \
  chown supysonic:users /var/lib/supysonic && \
  rm -rf /root/.ash_history /root/.cache /var/cache/apk/*

COPY docker /app

ENV \
  SUPYSONIC_DB_URI="sqlite:////var/lib/supysonic/supysonic.db" \
  SUPYSONIC_SCANNER_EXTENSIONS="" \
  SUPYSONIC_SECRET_KEY="" \
  SUPYSONIC_WEBAPP_CACHE_DIR="/var/lib/supysonic/cache" \
  SUPYSONIC_WEBAPP_LOG_FILE="/var/lib/supysonic/supysonic.log" \
  SUPYSONIC_WEBAPP_LOG_LEVEL="WARNING" \
  SUPYSONIC_DAEMON_LOG_FILE="/var/lib/supysonic/supysonic-daemon.log" \
  SUPYSONIC_DAEMON_LOG_LEVEL="INFO" \
  SUPYSONIC_LASTFM_API_KEY="" \
  SUPYSONIC_LASTFM_SECRET="" \
  SUPYSONIC_RUN_MODE="fcgi"

EXPOSE 5000

VOLUME [ "/var/lib/supysonic", "/media" ]

USER supysonic

ENTRYPOINT [ "/app/dockerrun.sh" ]
