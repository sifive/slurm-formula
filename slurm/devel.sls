## SLURM devel config

{% from "slurm/map.jinja" import slurm with context %}

include:
  - slurm
  - slurm.logdir

slurm_devel:
  {% if slurm.devel_pkgs != [] %}
  pkg.installed:
    - names: {{ slurm.devel_pkgs|yaml }}
  {% if slurm.slurm_version is defined %}
    - version: {{ slurm.slurm_version }}
  {% endif %}
  {% endif %}
