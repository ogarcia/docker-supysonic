# Supysonic container

[![forthebadge](https://forthebadge.com/images/badges/gluten-free.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/uses-python.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/it-works-dont-know-how.svg)](https://forthebadge.com)

(c) 2017-2025 [Connectical] Óscar García Amor

Redistribution, modifications and pull requests are welcomed under the terms
of GPLv3 license.

[Supysonic][sy] is a Python implementation of the [Subsonic][sb] server API.

This container packages **Supysonic** under [Alpine Linux][al], a lightweight
Linux distribution.

Visit [Quay][qu] or [GitLab][gl] to see all available tags.

[sy]: https://github.com/spl0k/supysonic
[sb]: http://www.subsonic.org
[al]: https://alpinelinux.org/
[qu]: https://quay.io/repository/connectical/supysonic
[gl]: https://gitlab.com/connectical/container/supysonic/container_registry

## Available tags

At this moment, the following images are building.

- **base**: default Supysonic image with SQLite support.
- **sql**: full SQL support (MySQL and PostgreSQL).
- **ffmpeg**: base image with ffmpeg added for transcoding.
- **ffmpeg-sql**: ffmpeg and full SQL support.
- **full**: all transcoding packages added (see `tags/full-packages`).
- **full-sql**: all packages and full SQL support.

Tag format used is as following.

- base: `VERSION-base`, `base`, `latest`
- sql: `VERSION-sql`, `sql`
- ffmpeg: `VERSION-ffmpeg`, `ffmpeg`
- ffmpeg-sql: `VERSION-ffmpeg-sql`,  `ffmpeg-sql`
- full: `VERSION-full`, `full`
- full-sql: `VERSION-full-sql`, `full-sql`

Old images are archived with format `VERSION-TAG`.

## Run

To run this container simply run.
```
alias docker="podman" # If you are using podman
docker run -d \
  --name=supysonic \
  -e SUPYSONIC_RUN_MODE=standalone \
  -p 5000:5000
  registry.gitlab.com/connectical/container/supysonic
```

This starts Supysonic in debug server mode over port 5000. You can go to
http://localhost:5000 to see it running and login using `admin` user with
same password.

Warning: this is a basic run, all data will be destroyed after container
stop and rm.

## Volumes

This container exports three volumes.

* `/media`: to your media collection.
* `/var/lib/supysonic`: Supysonic data, like database or sockets.
* `/var/log/supysonic`: Supysonic logs.

You can run the following to mount your media dir, store data and logs.
```
alias docker="podman" # If you are using podman
docker run -d \
  --name=supysonic \
  -v /my/supysonic/data:/var/lib/supysonic \
  -v /my/supysonic/logs:/var/log/supysonic \
  -v /my/media/directory:/media \
  registry.gitlab.com/connectical/container/supysonic
```

Take note that you must create before the data directory
`/my/supysonic/data` and logs directory `/my/supysonic/logs` and set
ownership to UID/GID 100 in both, otherwise the main proccess will crash.
```
mkdir -p /my/supysonic/data /my/supysonic/logs
chown -R 100:100 /my/supysonic/data /my/supysonic/logs
```

Once Supysonic has been started you will have a FastCGI file socket in the
permanent data volume `/my/supysonic/data/supysonic.sock` that you can use
with your web server.

## Configuration via container variables

The `configure.py` script that configures Supysonic use the following
container environment variables (please refer to [Supysonic readme][sr] to
know more about this settings).

| Variable | Default value |
| --- | --- |
| `SUPYSONIC_DB_URI` | sqlite:////var/lib/supysonic/supysonic.db |
| `SUPYSONIC_SCANNER_EXTENSIONS` | |
| `SUPYSONIC_SECRET_KEY` | |
| `SUPYSONIC_WEBAPP_CACHE_DIR` | /var/lib/supysonic/cache |
| `SUPYSONIC_WEBAPP_LOG_FILE` | /var/log/supysonic/supysonic.log |
| `SUPYSONIC_WEBAPP_LOG_LEVEL` | WARNING |
| `SUPYSONIC_DAEMON_ENABLED` | false |
| `SUPYSONIC_DAEMON_SOCKET` | /var/lib/supysonic/supysonic-daemon.sock |
| `SUPYSONIC_DAEMON_LOG_FILE` | /var/log/supysonic/supysonic-daemon.log |
| `SUPYSONIC_DAEMON_LOG_LEVEL` | INFO |
| `SUPYSONIC_LASTFM_API_KEY` | |
| `SUPYSONIC_LASTFM_SECRET` | |
| `SUPYSONIC_FCGI_PORT` | 5000 |
| `SUPYSONIC_FCGI_SOCKET` | /var/lib/supysonic/supysonic.sock |
| `SUPYSONIC_RUN_MODE` | fcgi |

Take note that:
- The paths are related to INSIDE container.
- Other parts of Supysonic config file that not are referred here (as
  transcoding or mimetypes) will be untouched, you can configure it by hand.
- At this moment the supported values for `SUPYSONIC_RUN_MODE` are only
  `fcgi` to FastCGI file socket, `fcgi-port` to FastCGI listen in a port and
  `standalone` to run a debug server on port 5000.

[sr]: https://github.com/spl0k/supysonic/blob/master/README.md

## Running a shell

If you need to enter in a shell to use `supysonic-cli` first run Supysonic
container as daemon and then enter on it with following command.

```
docker exec -t -i supysonic /bin/sh
```

Remember that `supysonic` is the run name, if you change it you must use the
same here.

## About Supysonic daemon

Supysonic comes with an optional [daemon service][ds] to perfom several
tasks as as library background scans or enable jukebox mode. The daemon is
disabled by default in this container image, but you can enable it setting
the container variable `SUPYSONIC_DAEMON_ENABLED` to `true`.

If you don't use jukebox mode and don't want to have a running process
wasting resources simply leave the variable as default and run the following
command in a [`systemd.timer`][st] or `cron` to update your media library.
```
docker exec supysonic /usr/local/bin/supysonic-cli folder scan
```

[ds]: https://supysonic.readthedocs.io/en/latest/setup/daemon.html
[st]: https://www.freedesktop.org/software/systemd/man/systemd.timer.html
