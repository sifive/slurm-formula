## SLURM DB devel config

{% from "slurm/map.jinja" import slurm with context %}

include:

slurm_db_devel:
  {% if slurm.db_devel_pkgs != [] %}
  pkg.installed:
    - names: {{ slurm.db_devel_pkgs|yaml }}
  {% if slurm.slurm_version is defined %}
    - version: {{ slurm.slurm_version }}
  {% endif %}
  {% endif %}
