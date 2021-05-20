## SLURM client config - same as common config

{% from "slurm/map.jinja" import slurm with context %}

include:
  - slurm.common
  - slurm

## Basic client config

slurm_client:
  pkg.installed:
    - names: {{ slurm.client_pkgs|yaml }}
{% if slurm.slurm_version is defined %}
    - version: {{ slurm.slurm_version }}
{% endif %}
    - require:
      - service: slurm_munge_service
{% if slurm.user_create|default(False) == True %}
      - user: slurm_user
{% endif %}
    - require_in:
      - file: slurm_config


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

