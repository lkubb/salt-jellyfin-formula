# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as jellyfin with context %}

include:
  - {{ sls_config_clean }}

{%- if jellyfin.install.autoupdate_service %}

Podman autoupdate service is disabled for Jellyfin:
{%-   if jellyfin.install.rootless %}
  compose.systemd_service_disabled:
    - user: {{ jellyfin.lookup.user.name }}
{%-   else %}
  service.disabled:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}

Jellyfin is absent:
  compose.removed:
    - name: {{ jellyfin.lookup.paths.compose }}
    - volumes: {{ jellyfin.install.remove_all_data_for_sure }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if jellyfin.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ jellyfin.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if jellyfin.install.rootless %}
    - user: {{ jellyfin.lookup.user.name }}
{%- endif %}
    - require:
      - sls: {{ sls_config_clean }}

Jellyfin compose file is absent:
  file.absent:
    - name: {{ jellyfin.lookup.paths.compose }}
    - require:
      - Jellyfin is absent

Jellyfin user session is not initialized at boot:
  compose.lingering_managed:
    - name: {{ jellyfin.lookup.user.name }}
    - enable: false
    - onlyif:
      - fun: user.info
        name: {{ jellyfin.lookup.user.name }}

Jellyfin user account is absent:
  user.absent:
    - name: {{ jellyfin.lookup.user.name }}
    - purge: {{ jellyfin.install.remove_all_data_for_sure }}
    - require:
      - Jellyfin is absent
    - retry:
        attempts: 5
        interval: 2

{%- if jellyfin.install.remove_all_data_for_sure %}

Jellyfin paths are absent:
  file.absent:
    - names:
      - {{ jellyfin.lookup.paths.base }}
    - require:
      - Jellyfin is absent
{%- endif %}
