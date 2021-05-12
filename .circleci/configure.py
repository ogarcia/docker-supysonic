#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2017-2021 Óscar García Amor <ogarcia@connectical.com>
#
# Distributed under terms of the GNU GPLv3 license.

import configparser
import os

class Config(object):
    def __init__(self, config_file='config.ini'):
        self.config_file = config_file
        self.config = configparser.ConfigParser()
        try:
            self.config.read(config_file)
        except Exception as e:
            err = 'config file is corrupted.\n{0}'.format(e)
            raise SystemExit(err)

    def set(self, section, option, envvar):
        if os.getenv(envvar):
            if section != 'DEFAULT' and not self.config.has_section(section):
                self.config.add_section(section)
            self.config.set(section, option, os.getenv(envvar))

    def stor(self):
        try:
            with open(self.config_file, 'w') as configfile:
                self.config.write(configfile)
        except Exception as e:
            err = 'cannot write in config file.\n{0}'.format(e)
            raise SystemExit(err)

if __name__ == '__main__':
    config = Config('/var/lib/supysonic/.supysonic')
    config.set('base',   'database_uri', 'SUPYSONIC_DB_URI')
    config.set('base',   'scanner_extensions', 'SUPYSONIC_SCANNER_EXTENSIONS')
    config.set('base',   'secret_key',   'SUPYSONIC_SECRET_KEY')
    config.set('webapp', 'cache_dir',    'SUPYSONIC_WEBAPP_CACHE_DIR')
    config.set('webapp', 'log_file',     'SUPYSONIC_WEBAPP_LOG_FILE')
    config.set('webapp', 'log_level',    'SUPYSONIC_WEBAPP_LOG_LEVEL')
    config.set('daemon', 'socket',       'SUPYSONIC_DAEMON_SOCKET')
    config.set('daemon', 'log_file',     'SUPYSONIC_DAEMON_LOG_FILE')
    config.set('daemon', 'log_level',    'SUPYSONIC_DAEMON_LOG_LEVEL')
    config.set('lastfm', 'api_key',      'SUPYSONIC_LASTFM_API_KEY')
    config.set('lastfm', 'secret',       'SUPYSONIC_LASTFM_SECRET')
    config.stor()
