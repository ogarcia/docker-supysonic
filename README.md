# Supysonic container

**This project is no longer maintained and will not receive further updates.**

(c) 2017-2026 [Connectical] Óscar García Amor

For years this repository packaged [Supysonic][sy] under [Alpine Linux][al].
It has been retired, simply because I no longer run Supysonic myself: these
days I use [Tocata][to], and a container I don't use is a container I end up
neglecting. No new images will be built, neither for new Supysonic commits
nor for new Alpine base images. The images already published on [Quay][qu]
and [GitLab][gl] stay where they are, but they will not get any security
fixes.

The last state of the repository, with the `Containerfile`, the tag variants
and the full documentation, is kept in the [`archive`][ar] branch for anybody
who wants to keep building it on their own.

This is not a judgement on Supysonic, which I have contributed to and which
remains a solid project. If it suits you, keep using it.

[sy]: https://github.com/spl0k/supysonic
[al]: https://alpinelinux.org/
[qu]: https://quay.io/repository/connectical/supysonic
[gl]: https://gitlab.com/connectical/container/supysonic/container_registry
[ar]: https://gitlab.com/connectical/container/supysonic/-/tree/archive

## Tocata and Supysonic

[Tocata][to] is an [OpenSubsonic][os] compatible music server written in
Rust. Its presentation page, with screenshots of the panel, is at
[tocata.ogarcia.me][tw]. Both servers speak the same family of protocols, so
your players keep working; what changes is what sits behind them.

[to]: https://github.com/ogarcia/tocata
[os]: https://opensubsonic.netlify.app/
[tw]: https://tocata.ogarcia.me/

### Where Tocata is better

- **One static binary.** Server and administration panel ship in a single
  binary, statically linked against musl. No Python runtime, no FastCGI
  socket and no web server in front of it. An official image is published by
  the project, so a custom container like this one is not needed.
- **Much lighter and faster.** It indexes a collection of almost twelve
  thousand songs and plays them in around twenty megabytes of memory.
- **Everything from the panel.** Collections, users, who may reach which
  collection, scans and their results are managed from the web panel, with no
  CLI and no separate daemon to keep running.
- **OpenSubsonic extensions.** API keys (`apiKeyAuthentication`), timed lyrics
  (`songLyrics`), top songs by artist, playback reports and index based play
  queues.
- **Careful authentication.** Passwords stored as Argon2id hashes, panel
  sessions that can be listed and closed one by one, and per-client API keys
  that can be revoked individually.

### Where Supysonic is still the better choice

Being honest, there are things Supysonic does and Tocata does not, by design:

- **Transcoding.** Supysonic can transcode on the fly with ffmpeg or other
  tools (the `ffmpeg` and `full` tags of this image). Tocata serves files
  exactly as they are on disk and has no transcoder in it. If you stream to
  mobile devices over slow links, or keep formats your players cannot decode,
  this matters.
- **Other database backends.** Supysonic can use MySQL or PostgreSQL besides
  SQLite (the `sql` tags of this image). Tocata only uses SQLite. If you run a
  large installation, or prefer your data in a database server you already
  operate and back up, Supysonic fits better.
- **Jukebox mode.** Supysonic's daemon can play music through the speakers
  attached to the server. Tocata does not answer `jukeboxControl`.
- **Last.fm.** Supysonic scrobbles to Last.fm. Tocata scrobbles through the
  ListenBrainz protocol instead.

If none of those is something you rely on, moving to Tocata is
straightforward.

### Quick start

```sh
alias docker="podman" # If you are using podman
docker run -d --name tocata \
  -p 4224:4224 \
  -v tocata-data:/data \
  -v /my/media/directory:/media:ro \
  ghcr.io/ogarcia/tocata:latest
```

On the first run Tocata creates an `admin` account and writes its generated
password to the log, once. The panel is then at http://localhost:4224/, where
you add `/media` (or a directory inside it) as a collection and start the
first scan.

Nothing is carried over from Supysonic: Tocata builds its own catalogue from
the music files, so users, stars and playlists have to be set up again. In
your players, change the server address and use either an API key or the
plain (legacy) password authentication: token authentication is refused on
purpose, since it cannot coexist with hashed passwords.

Everything else, from prebuilt binaries to environment variables and
authentication details, is in the [Tocata README][tr].

[tr]: https://github.com/ogarcia/tocata#readme
