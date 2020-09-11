## SLURM client config - same as common config

{% from "slurm/map.jinja" import slurm with context %}

include:
  - slurm

## Basic client config

slurm_client:
  pkg.installed:
    - names: {{ slurm.client_pkgs|yaml }}
{% if slurm.slurm_version is defined %}
    - version: {{ slurm.slurm_version }}
{% endif %}

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


## X login client utility if slurm:X is true

{% if salt['pillar.get']('slurm:X', False) %}

slurm_srun_x:
  file.managed:
    - name: {{slurm.bindir}}/srun-x
    - template: jinja
    - source: salt://slurm/files/srun-x.sh.jinja
    - context:
        slurm: {{ slurm }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'

slurm_srun_x_start:
  file.managed:
    - name: {{slurm.bindir}}/srun-x-start
    - template: jinja
    - source: salt://slurm/files/srun-x-start.sh.jinja
    - user: 'root'
    - group: 'root'
    - mode: '0755'


{% endif %}

