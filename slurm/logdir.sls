## SLURM log file setup

{% from "slurm/map.jinja" import slurm with context %}

slurm_logdir:
  file.directory:
    - name: {{ slurm.logdir }}
    - user: {{ slurm.slurm_user }}
    - group: {{ slurm.slurm_group }}
    - mode: '0755'

