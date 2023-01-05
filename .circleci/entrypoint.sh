#! /bin/sh
#
# entrypoint.sh
# Copyright (C) 2017-2023 Óscar García Amor <ogarcia@connectical.com>
#
# Distributed under terms of the GNU GPLv3 license.
#

# Create empty config file if not exists
if ! test -f /var/lib/supysonic/.supysonic; then
  touch /var/lib/supysonic/.supysonic
fi

# Configure with environment vars
supysonic-configure

# Create sample sqlite database if not database file is present and user
# wants to use it
if ! test -f /var/lib/supysonic/supysonic.db && \
  test "${SUPYSONIC_DB_URI}" == "sqlite:////var/lib/supysonic/supysonic.db"
then
  supysonic-cli user add admin -p admin
  supysonic-cli user setroles --admin admin
fi

# Function to run optional daemon for background tasks
function daemon {
  [ "${SUPYSONIC_DAEMON_ENABLED}" == true ] && {
    sleep 10 && /usr/local/bin/python3 -m supysonic.daemon &
  }
}

# Function to make a small python fcgi script and run it
function fcgi {
  cat > /tmp/supysonic.fcgi << EOF
from flup.server.fcgi import WSGIServer
from supysonic.web import create_application
app = create_application()
WSGIServer(app, bindAddress='${SUPYSONIC_FCGI_SOCKET}', umask=0).run()
EOF
  exec /usr/local/bin/python /tmp/supysonic.fcgi
}

# Function to make a small python fcgi script that listen in a port and run it
function fcgiport {
  cat > /tmp/supysonic-port.fcgi << EOF
from flup.server.fcgi import WSGIServer
from supysonic.web import create_application
app = create_application()
WSGIServer(app, bindAddress=('0.0.0.0', ${SUPYSONIC_FCGI_PORT})).run()
EOF
  exec /usr/local/bin/python /tmp/supysonic-port.fcgi
}


# Function to run standalone
function standalone {
  FLASK_APP="supysonic.web:create_application()"
  export FLASK_APP
  FLASK_ENV=development
  export FLASK_ENV
  flask run -h 0.0.0.0
}

# Exec CMD or supysonic by default if nothing present
if [ $# -gt 0 ];then
  exec "$@"
else
  case ${SUPYSONIC_RUN_MODE} in
    fcgi)
      daemon
      fcgi
      ;;
    fcgi-port)
      daemon
      fcgiport
      ;;
    standalone)
      daemon
      standalone
      ;;
    *)
      echo "Run mode not recognized, switching to standalone debug server mode"
      daemon
      standalone
      ;;
  esac
fi
