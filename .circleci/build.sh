#! /bin/sh
#
# build.sh
# Copyright (C) 2021-2022 Óscar García Amor <ogarcia@connectical.com>
#
# Distributed under terms of the GNU GPLv3 license.
#


# upgrade
apk -U --no-progress upgrade

# install build deps
apk --no-progress add gcc musl-dev zlib-dev jpeg-dev libjpeg-turbo

# install python deps
pip install flup

# extract software
cd /supysonic/src/
tar xzf supysonic.tar.gz

# install supysonic
cd supysonic-*
python setup.py install

# create supysonic package
install -d -m755 "/supysonic/pkg/usr/bin"
install -m755 "/supysonic/build/configure.py" \
  "/supysonic/pkg/usr/bin/supysonic-configure"
install -m755 "/supysonic/build/entrypoint.sh" \
  "/supysonic/pkg/entrypoint.sh"
mv "/usr/local" "/supysonic/pkg/usr"
install -d -m755 -o100 -g100 "/supysonic/pkg/var/lib/supysonic" \
  "/supysonic/pkg/var/log/supysonic"

# create supysonic user
deluser utmp # remove utmp to reuse uid 100
adduser -S -D -H -h /var/lib/supysonic -s /sbin/nologin -G users \
  -g supysonic supysonic
install -d -m755 "/supysonic/pkg/etc"
install -m644 "/etc/passwd" "/supysonic/pkg/etc/passwd"
install -m644 "/etc/group" "/supysonic/pkg/etc/group"
install -m640 -gshadow "/etc/shadow" "/supysonic/pkg/etc/shadow"
