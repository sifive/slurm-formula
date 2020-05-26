## SLURM slurmbdb daemon config

{% from "slurm/map.jinja" import slurm with context %}

include:
  - slurm
  - slurm.logdir

slurm_db:
  pkg.installed:
    - pkgs: {{ slurm.db_pkgs|yaml }}
  service.running:
    - enable: True
    - name: {{ slurm.slurmdbd }}
    - require:
      - file: slurm_logdir
      - pkg: slurm_db
      - service: slurm_munge_service
{% if salt['pillar.get']('slurm:restart:db', False) %}
    - watch:
      - file: slurm_db_config
{% endif %}

slurm_db_config:
  file.managed:
    - name: {{slurm.etcdir}}/slurmdbd.conf
    - user: root
    - group: root
    - mode: '0644'
    - template: jinja 
    - source: salt://slurm/files/slurmdbd.conf.jinja
    - context:
        slurm: {{ slurm }}

slurm_db_default:
  file.managed:
    - name: /etc/default/{{slurm.slurmdbd}}
    - require:
      - pkg: slurm_db
    - require_in:
      - service: slurm_db



{################
slurmdbd:
  cmd.run:
    - name: /usr/bin/sacctmgr -i add cluster "{{ salt['pillar.get']('slurm:ClusterName','slurm') }}"
    - unless: sacctmgr show Cluster |grep -i "{{ salt['pillar.get']('slurm:ClusterName','slurm') }}"
  file.touch:
    - name: /etc/default/slurmdbd
    - onlyif:
       - file: exist_default_slurmdb
  
##################}
