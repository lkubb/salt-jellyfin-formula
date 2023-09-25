# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as jellyfin with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

Jellyfin environment files are managed:
  file.managed:
    - names:
      - {{ jellyfin.lookup.paths.config_jellyfin }}:
        - source: {{ files_switch(
                        ["jellyfin.env", "jellyfin.env.j2"],
                        config=jellyfin,
                        lookup="jellyfin environment file is managed",
                        indent_width=10,
                     )
                  }}
    - mode: '0640'
    - user: root
    - group: __slot__:salt:user.primary_group({{ jellyfin.lookup.user.name }})
    - makedirs: true
    - template: jinja
    - require:
      - user: {{ jellyfin.lookup.user.name }}
    - require_in:
      - Jellyfin is installed
    - context:
        jellyfin: {{ jellyfin | json }}

Jellyfin xml config files are managed:
  file.serialize:
    - names:
      - {{ jellyfin.lookup.paths.data | path_join("config", "system.xml") }}:
        - dataset: {{ {"ServerConfiguration": jellyfin.config.system} | json }}
      - {{ jellyfin.lookup.paths.data | path_join("config", "network.xml") }}:
        - dataset: {{ {"NetworkConfiguration": jellyfin.config.network} | json }}
      - {{ jellyfin.lookup.paths.data | path_join("config", "encoding.xml") }}:
        - dataset: {{ {"EncodingOptions": jellyfin.config.encoding} | json }}
    - create: false
    - require:
      - user: {{ jellyfin.lookup.user.name }}
      - Custom Jellyfin xml serializer is installed
    - serializer: jellyfin_xml
    - merge_if_exists: true
