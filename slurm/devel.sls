## SLURM devel config

{% from "slurm/map.jinja" import slurm with context %}

include:
  - slurm
  - slurm.logdir

slurm_devel:
  {% if slurm.devel_pkgs != [] %}
  pkg.installed:
    - pkgs: {{ slurm.devel_pkgs }}
  {% endif %}
