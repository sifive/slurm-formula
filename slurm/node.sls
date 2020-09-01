## SLURM compute node config

{% from "slurm/map.jinja" import slurm with context %}

include:
  - slurm
  - slurm.logdir

slurm_node:
  {% if slurm.node_pkgs != [] %}
  pkg.installed:
    - names: {{ slurm.node_pkgs|yaml }}
  {% if slurm.slurm_version is defined %}
    - version: {{ slurm.slurm_version }}
  {% endif %}
  {% endif %}
  service.running:
    - name: {{ slurm.slurmd }}
    - enable: True
    - require:
      - file: slurm_config
      - file: slurm_config_energy
      - file: slurm_logdir
      {%  if salt['pillar.get']('slurm:AuthType', 'munge') == 'munge' %}
      - service: munge
      {%endif %}
   {% if salt['pillar.get']('slurm:restart:node', False) %}
    - watch:
       - file: slurm_config
   {% endif %}

slurm_node_default:
  file.managed:
    - name: /etc/default/{{slurm.slurmd}}
    - require:
      - pkg: slurm_node
    - require_in:
      - service: slurm_node

slurm_node_state:
  file.directory:
    - name: {{slurm.slurmddir}}
    - require:
        - pkg: slurm_node
    - require_in:
        - service: slurm_node
    - user: slurm
    - group: slurm
    - mode: '0755'
    - makedirs: true



{% if slurm.use_cgroup %}
slurm_cgroup:
  file.managed:
    - name: {{slurm.etcdir}}/cgroup.conf 
    - user: slurm
    - group: root
    - mode: 400
    - template: jinja
    - source: salt://slurm/files/cgroup.conf.jinja
    - context:
        slurm: {{ slurm }}
    - require:
      - file: slurm_node_state
    - require_in:
      - service: slurm_node
{% endif %}

{% set gres = salt['pillar.get']('slurm:gres') -%}
{% if gres is mapping %}
slurm_gres::
  file.managed:
    - name: {{slurm.etcdir}}/gres.conf 
    - user: slurm
    - group: root
    - mode: 0444
    - template: jinja
    - source: salt://slurm/files/gres.conf.jinja
    - context:
        slurm: {{ slurm }}
        gres: {{ gres }}
    - require:
      - file: slurm_node_state
    - require_in:
      - service: slurm_node
{% endif %}


{% if salt['pillar.get']('slurm:TopologyPlugin') in ['tree','3d_torus'] -%}
slurm_topolgy:
  file.managed:
    - name: {{slurm.etcdir}}/topology.conf
    - user: slurm
    - group: root
    - mode: '0644'
    - template: jinja
    - source: salt://slurm/files/topology.conf.jinja
    - context:
        slurm: {{ slurm }}
    - require:
      - pkg: slurm_client
{% endif %}


slurm_config_energy:
  file.managed:
    - name: {{slurm.etcdir}}/acct_gather.conf
    - user: slurm
    - group: root
    - mode: 644
    - template: jinja
    - source: salt://slurm/files/acct_gather.conf.jinja
    - context:
        slurm: {{ slurm }}
    - require:
      - pkg: slurm_client

## X login node utilities if slurm:X is true

{% if salt['pillar.get']('slurm:X', False) %}

slurm_srun_x_session:
  file.managed:
    - name: {{slurm.bindir}}/srun-x-session
    - template: jinja
    - source: salt://slurm/files/srun-x-session.sh.jinja
    - user: 'root'
    - group: 'root'
    - mode: '0755'

slurm_screen:
  pkg.installed:
    - pkgs: {{ slurm.screen_pkgs|yaml }}

{% endif %}
