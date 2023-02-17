Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``jellyfin``
^^^^^^^^^^^^
*Meta-state*.

This installs the jellyfin containers,
manages their configuration and starts their services.


``jellyfin.package``
^^^^^^^^^^^^^^^^^^^^
Installs the jellyfin containers only.
This includes creating systemd service units.


``jellyfin.config``
^^^^^^^^^^^^^^^^^^^
Manages the configuration of the jellyfin containers.
Has a dependency on `jellyfin.package`_.


``jellyfin.service``
^^^^^^^^^^^^^^^^^^^^
Starts the jellyfin container services
and enables them at boot time.
Has a dependency on `jellyfin.config`_.


``jellyfin.clean``
^^^^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``jellyfin`` meta-state
in reverse order, i.e. stops the jellyfin services,
removes their configuration and then removes their containers.


``jellyfin.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the jellyfin containers
and the corresponding user account and service units.
Has a depency on `jellyfin.config.clean`_.
If ``remove_all_data_for_sure`` was set, also removes all data.


``jellyfin.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the jellyfin containers
and has a dependency on `jellyfin.service.clean`_.

This does not lead to the containers/services being rebuilt
and thus differs from the usual behavior.


``jellyfin.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^
Stops the jellyfin container services
and disables them at boot time.


