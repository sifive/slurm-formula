## SLURM openlava config

{% from "slurm/map.jinja" import slurm with context %}

include:
  - slurm
  - slurm.logdir

slurm_openlava:
  {% if slurm.openlava_pkgs != [] %}
  pkg.installed:
    - names: {{ slurm.openlava_pkgs|yaml }}
  {% if slurm.slurm_version is defined %}
    - version: {{ slurm.slurm_version }}
  {% endif %}
  {% endif %}
