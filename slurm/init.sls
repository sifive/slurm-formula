## SLURM config

{% from "slurm/map.jinja" import slurm with context %}

include:
  - slurm.common

slurm_config:
  file.managed:
    - name: {{slurm.etcdir}}/slurm.conf
    - user: {{slurm.slurm_user}}
    - group: root
    - mode: '0644'
    - template: jinja
    - source: salt://slurm/files/slurm.conf.jinja
    - context:
        slurm: {{ slurm }}
    - require:
        - file: slurm_etcdir

