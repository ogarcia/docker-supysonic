#! /bin/sh
#
# run.sh
# Copyright (C) 2017-2020 Óscar García Amor <ogarcia@connectical.com>
#
# Distributed under terms of the GNU GPLv3 license.
#

# Copy sample file if not exists
if ! test -f /var/lib/supysonic/.supysonic; then
  cp /app/config.sample /var/lib/supysonic/.supysonic
fi

# Copy sample sqlite database if not database file is present and user wants
# to use it
if ! test -f /var/lib/supysonic/supysonic.db && \
  test "${SUPYSONIC_DB_URI}" == "sqlite:////var/lib/supysonic/supysonic.db"
then
  cp /app/dockersqlite.db /var/lib/supysonic/supysonic.db
fi

# Configure with environment vars
/usr/local/bin/python /app/dockerconfig.py

# Exec CMD or supysonic by default if nothing present
if [ $# -gt 0 ];then
  exec "$@"
else
  case ${SUPYSONIC_RUN_MODE} in
    fcgi)
      # Make a small python fcgi script and run it
      cat > /tmp/supysonic.fcgi << EOF
from flup.server.fcgi import WSGIServer
from supysonic.web import create_application
app = create_application()
WSGIServer(app, bindAddress='/var/lib/supysonic/supysonic.sock', umask=0).run()
EOF
      exec /usr/local/bin/python /tmp/supysonic.fcgi
      ;;
    standalone)
      exec /usr/local/bin/python /app/server.py 0.0.0.0
      ;;
    *)
      echo "Run mode not recognized, switching to standalone debug server mode" 
      exec /usr/local/bin/python /app/server.py 0.0.0.0
      ;;
  esac
fi
