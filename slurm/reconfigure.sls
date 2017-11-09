## SLURM reload state

{% from "slurm/map.jinja" import slurm with context %}
include:
  - slurm
  - slurm.logdir


slurm_server_reload:
  cmd.run:
    - name: {{ slurm.scontrol }} reconfigure
    - require:
      - file: slurm_config
