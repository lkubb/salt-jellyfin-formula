# vim: ft=sls

{#-
    Starts the jellyfin container services
    and enables them at boot time.
    Has a dependency on `jellyfin.config`_.
#}

include:
  - .running
