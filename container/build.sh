#! /bin/sh
#
# build.sh
# Copyright (C) 2021-2025 Óscar García Amor <ogarcia@connectical.com>
#
# Distributed under terms of the GNU GPLv3 license.
#

# upgrade
apk -U --no-progress upgrade

# install build deps
apk --no-progress add gcc musl-dev sqlite-dev zlib-dev jpeg-dev libjpeg-turbo

# install python deps
pip install flup
[[ ${CONTAINER_TAG} == *sql ]] && \
  pip install pymysql psycopg2-binary

# extract software
cd /supysonic/src/
tar xzf supysonic.tar.gz

# install supysonic
cd supysonic-*
pip install .

# create supysonic package
install -d -m755 "/supysonic/pkg/usr/bin"
install -m755 "/supysonic/build/configure.py" \
  "/supysonic/pkg/usr/bin/supysonic-configure"
install -m755 "/supysonic/build/entrypoint.sh" \
  "/supysonic/pkg/entrypoint.sh"
mv "/usr/local" "/supysonic/pkg/usr"
install -d -m755 -o100 -g100 "/supysonic/pkg/var/lib/supysonic" \
  "/supysonic/pkg/var/log/supysonic"
