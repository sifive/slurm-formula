## SLURM PAM integration 

{% from "slurm/map.jinja" import slurm with context %}

slurm_pam:
  {% if slurm.pam_pkgs != [] %}
  pkg.installed:
    - names: {{ slurm.pam_pkgs|yaml }}
  {% if slurm.slurm_version is defined %}
    - version: {{ slurm.slurm_version }}
  {% endif %}
  {% endif %}
