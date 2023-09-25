# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- from tplroot ~ "/map.jinja" import mapdata as jellyfin with context %}

include:
  - {{ sls_config_file }}

Jellyfin service is enabled:
  compose.enabled:
    - name: {{ jellyfin.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if jellyfin.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ jellyfin.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
    - require:
      - Jellyfin is installed
{%- if jellyfin.install.rootless %}
    - user: {{ jellyfin.lookup.user.name }}
{%- endif %}

Jellyfin service is running:
  compose.running:
    - name: {{ jellyfin.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if jellyfin.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ jellyfin.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if jellyfin.install.rootless %}
    - user: {{ jellyfin.lookup.user.name }}
{%- endif %}
    - watch:
      - Jellyfin is installed
      - sls: {{ sls_config_file }}
