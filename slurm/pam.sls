## SLURM PAM integration 

{% from "slurm/map.jinja" import slurm with context %}

slurm_pam
  {% if slurm.pam_pkgs != [] %}
  pkg.installed:
    - pkgs: {{ slurm.pam_pkgs }}
  {% endif %}
