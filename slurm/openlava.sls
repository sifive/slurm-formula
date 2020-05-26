## SLURM openlava config

{% from "slurm/map.jinja" import slurm with context %}

include:
  - slurm
  - slurm.logdir

slurm_openlava:
  {% if slurm.openlava_pkgs != [] %}
  pkg.installed:
    - pkgs: {{ slurm.openlava_pkgs|yaml }}
  {% endif %}
