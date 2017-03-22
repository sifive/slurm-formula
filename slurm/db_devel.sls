## SLURM DB devel config

{% from "slurm/map.jinja" import slurm with context %}

include:

slurm_db_devel:
  {% if slurm.db_devel_pkgs != [] %}
  pkg.installed:
    - pkgs: {{ slurm.db_devel_pkgs }}
    - skip_verify: true
  {% endif %}
