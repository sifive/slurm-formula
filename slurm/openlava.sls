## SLURM openlava config

{% from "slurm/map.jinja" import slurm with context %}

include:
  - slurm
  - slurm.logdir

slurm_openlava:
  {% if slurm.openlava_pkgs != [] %}
  pkg.installed:
    - names: {{ slurm.openlava_pkgs|yaml }}
  {% endif %}

slurm_openlava_extras:
  {% if slurm.openlava_extra_pkgs != [] %}
  pkg.installed:
    - names: {{ slurm.openlava_extra_pkgs|yaml }}
  {% endif %}
