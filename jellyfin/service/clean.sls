# vim: ft=sls


{#-
    Stops the jellyfin container services
    and disables them at boot time.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as jellyfin with context %}

jellyfin service is dead:
  compose.dead:
    - name: {{ jellyfin.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if jellyfin.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ jellyfin.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if jellyfin.install.rootless %}
    - user: {{ jellyfin.lookup.user.name }}
{%- endif %}

jellyfin service is disabled:
  compose.disabled:
    - name: {{ jellyfin.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if jellyfin.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ jellyfin.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if jellyfin.install.rootless %}
    - user: {{ jellyfin.lookup.user.name }}
{%- endif %}
