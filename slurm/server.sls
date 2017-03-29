## SLURM control daemon config

{% from "slurm/map.jinja" import slurm with context %}
include:
  - slurm
  - slurm.logdir

slurm_server:
  {% if slurm.server_pkgs != [] %}
  pkg.installed:
    - pkgs: {{ slurm.server_pkgs }}
    - require:
      # slurm packages require valid config else they do not start up
      - file: slurm_config
  {% endif %}
  service.running:
    - enable: True
    - name: {{ slurm.slurmctld }}
    - require:
      - file: slurm_config
      - file: slurm_logdir
      {%  if salt['pillar.get']('slurm:AuthType', 'munge') == 'munge' %}
      - service: munge
      {%endif %}
{% if slurm.restart.db|default(False) %}
    - watch:
        - file: slurm_config
{% endif %}

slurm_server_default:
  file.managed:
    - name: /etc/default/{{slurm.slurmctld}}
    - require:
      - pkg: slurm_server
    - require_in:
      - service: slurm_server

slurm_server_state:
  file.directory:
    - name: {{slurm.slurmctlddir}}
    - require:
        - pkg: slurm_server
    - require_in:
        - service: slurm_server
    - user: slurm
    - group: slurm
    - mode: '0755'
    - makedirs: true


slurm_server_reload:
  cmd.run:
    - name: {{ slurm.scontrol }} reconfigure
    - require:
      - file: slurm_config
    - onchanges:
      - file: slurm_config
