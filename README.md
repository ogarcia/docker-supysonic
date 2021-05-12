# Supysonic docker [![CircleCI](https://circleci.com/gh/ogarcia/docker-supysonic.svg?style=svg)](https://circleci.com/gh/ogarcia/docker-supysonic)

(c) 2017-2021 Óscar García Amor

Redistribution, modifications and pull requests are welcomed under the terms
of GPLv3 license.

[Supysonic][1] is a Python implementation of the [Subsonic][2] server API.

This docker packages **Supysonic** under [Alpine Linux][3], a lightweight
Linux distribution.

Visit [Docker Hub][4] or [Quay][5] to see all available tags.

[1]: https://github.com/spl0k/supysonic
[2]: http://www.subsonic.org
[3]: https://alpinelinux.org/
[4]: https://hub.docker.com/r/ogarcia/supysonic/
[5]: https://quay.io/repository/ogarcia/supysonic

## Run

To run this container exposing Supysonic over a FastCGI file socket in the
permanent data volume, mounting your `/media` and using sqlite backend,
simply run.

```
docker run -d \
  --name=supysonic \
  -v /srv/supysonic:/var/lib/supysonic \
  -v /srv/supysonic/log:/var/log/supysonic \
  -v /media:/media \
  ogarcia/supysonic
```

This starts Supysonic with a preconfiguration in database so you can login
using `admin` user with same password.

## Configuration via Docker variables

The `configure.py` script that configures Supysonic use the following Docker
environment variables (please refer to [Supysonic readme][6] to know more
about this settings).

| Variable | Default value |
| --- | --- |
| `SUPYSONIC_DB_URI` | sqlite:////var/lib/supysonic/supysonic.db |
| `SUPYSONIC_SCANNER_EXTENSIONS` | |
| `SUPYSONIC_SECRET_KEY` | |
| `SUPYSONIC_WEBAPP_CACHE_DIR` | /var/lib/supysonic/cache |
| `SUPYSONIC_WEBAPP_LOG_FILE` | /var/log/supysonic/supysonic.log |
| `SUPYSONIC_WEBAPP_LOG_LEVEL` | WARNING |
| `SUPYSONIC_DAEMON_SOCKET` | /var/lib/supysonic/supysonic-daemon.sock |
| `SUPYSONIC_DAEMON_LOG_FILE` | /var/log/supysonic/supysonic-daemon.log |
| `SUPYSONIC_DAEMON_LOG_LEVEL` | INFO |
| `SUPYSONIC_LASTFM_API_KEY` | |
| `SUPYSONIC_LASTFM_SECRET` | |
| `SUPYSONIC_FCGI_SOCKET` | /var/lib/supysonic/supysonic.sock |
| `SUPYSONIC_RUN_MODE` | fcgi |

Take note that:
- The paths are related to INSIDE Docker.
- Other parts of Supysonic config file that not are referred here (as
  transcoding or mimetypes) will be untouched, you can configure it by hand.
- At this moment the supported values for `SUPYSONIC_RUN_MODE` are only
  `fcgi` to FastCGI file socket and `standalone` to run a debug server on
  port 5000.

[6]: https://github.com/spl0k/supysonic/blob/master/README.md

## Running a shell

If you need to enter in a shell to use `supysonic-cli` first run Supysonic
Docker as daemon and then enter on it with following command.

```
docker exec -t -i supysonic /bin/sh
```

Remember that `supysonic` is the run name, if you change it you must use the
same here.
