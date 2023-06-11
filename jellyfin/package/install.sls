# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as jellyfin with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

Jellyfin user account is present:
  user.present:
{%- for param, val in jellyfin.lookup.user.items() %}
{%-   if val is not none and param not in ["groups", "gid"] %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - usergroup: true
    - createhome: true
    - groups: {{ jellyfin.lookup.user.groups | json }}
    # (on Debian 11) subuid/subgid are only added automatically for non-system users
    - system: false
{%- if not jellyfin.lookup.media_group.gid %}]
    - gid: {{ jellyfin.lookup.user.gid or "null" }}
{%- else %}
    - gid: {{ jellyfin.lookup.media_group.gid }}
    - require:
      - group: {{ jellyfin.lookup.media_group.name }}
  group.present:
    - name: {{ jellyfin.lookup.media_group.name }}
    - gid: {{ jellyfin.lookup.media_group.gid }}
{%- endif %}

Jellyfin user session is initialized at boot:
  compose.lingering_managed:
    - name: {{ jellyfin.lookup.user.name }}
    - enable: {{ jellyfin.install.rootless }}
    - require:
      - user: {{ jellyfin.lookup.user.name }}

Jellyfin paths are present:
  file.directory:
    - names:
      - {{ jellyfin.lookup.paths.base }}
    - user: {{ jellyfin.lookup.user.name }}
    - group: __slot__:salt:user.primary_group({{ jellyfin.lookup.user.name }})
    - makedirs: true
    - require:
      - user: {{ jellyfin.lookup.user.name }}

{%- if jellyfin.install.podman_api %}

Jellyfin podman API is enabled:
  compose.systemd_service_enabled:
    - name: podman.socket
    - user: {{ jellyfin.lookup.user.name }}
    - require:
      - Jellyfin user session is initialized at boot

Jellyfin podman API is available:
  compose.systemd_service_running:
    - name: podman.socket
    - user: {{ jellyfin.lookup.user.name }}
    - require:
      - Jellyfin user session is initialized at boot
{%- endif %}

Jellyfin compose file is managed:
  file.managed:
    - name: {{ jellyfin.lookup.paths.compose }}
    - source: {{ files_switch(
                    ["docker-compose.yml", "docker-compose.yml.j2"],
                    config=jellyfin,
                    lookup="Jellyfin compose file is present",
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ jellyfin.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - makedirs: true
    - context:
        jellyfin: {{ jellyfin | json }}

Jellyfin is installed:
  compose.installed:
    - name: {{ jellyfin.lookup.paths.compose }}
{%- for param, val in jellyfin.lookup.compose.items() %}
{%-   if val is not none and param != "service" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
{%- if jellyfin.container.userns_keep_id and jellyfin.install.rootless and jellyfin.lookup.compose.create_pod is false %}
    - podman_create_args:
{#-     post-map.jinja ensures this is in pod_args if pods are in use #}
        # this maps the host uid/gid to the same ones inside the container
        # important for network share access
        # https://github.com/containers/podman/issues/5239#issuecomment-587175806
      - userns: keep-id
{%- endif %}
{%- for param, val in jellyfin.lookup.compose.service.items() %}
{%-   if val is not none %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - watch:
      - file: {{ jellyfin.lookup.paths.compose }}
{%- if jellyfin.install.rootless %}
    - user: {{ jellyfin.lookup.user.name }}
    - require:
      - user: {{ jellyfin.lookup.user.name }}
{%- endif %}

Custom Jellyfin xml serializer is installed:
  saltutil.sync_serializers:
    - refresh: true

{%- if jellyfin.install.autoupdate_service is not none %}

Podman autoupdate service is managed for Jellyfin:
{%-   if jellyfin.install.rootless %}
  compose.systemd_service_{{ "enabled" if jellyfin.install.autoupdate_service else "disabled" }}:
    - user: {{ jellyfin.lookup.user.name }}
{%-   else %}
  service.{{ "enabled" if jellyfin.install.autoupdate_service else "disabled" }}:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}
