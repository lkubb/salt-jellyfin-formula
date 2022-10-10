# -*- coding: utf-8 -*-
# vim: ft=yaml
---
jellyfin:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value
    compose:
      create_pod: null
      pod_args: null
      project_name: jellyfin
      remove_orphans: true
      build: false
      build_args: null
      pull: false
      service:
        container_prefix: null
        ephemeral: true
        pod_prefix: null
        restart_policy: on-failure
        restart_sec: 2
        separator: null
        stop_timeout: null
    paths:
      base: /opt/containers/jellyfin
      compose: docker-compose.yml
      config_jellyfin: jellyfin.env
      cache: ''
      data: data
    user:
      groups: []
      home: null
      name: jellyfin
      shell: /usr/sbin/nologin
      uid: null
      gid: null
    containers:
      jellyfin:
        image: docker.io/jellyfin/jellyfin:latest
    media_group:
      gid: 3414
      name: mediarr
  install:
    rootless: true
    autoupdate: true
    autoupdate_service: false
    remove_all_data_for_sure: false
  config:
    encoding: {}
    general:
      FFmpeg:analyzeduration: null
      FFmpeg:probesize: null
      HttpListenerHost:DefaultRedirectPath: null
      InstallationManager:PluginManifestUrl: null
      PublishedServerUrl: null
      hostwebclient: null
      playlists:allowDuplicates: null
    network:
      HttpServerPortNumber: 8096
      HttpsPortNumber: 8920
    system: {}
  container:
    host_port: 3771
    host_port_https: 3772
    pass_autodiscovery: false
    pass_https: false
    pgid: null
    puid: null
    userns_keep_id: true
  mount_paths: []

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # Default path: salt://< path_prefix >/< dirs.files >/< dirs.default >
    #         I.e.: salt://jellyfin/files/default
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   jellyfin-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

    # For testing purposes
    source_files:
      Jellyfin environment file is managed:
      - jellyfin.env.j2

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
