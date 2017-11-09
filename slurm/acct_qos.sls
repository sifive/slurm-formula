## SLURM state for setting up QOSs

{% from "slurm/map.jinja" import slurm with context %}
include:
  - slurm
  - slurm.logdir

{% set sacctmgr = 'sacctmgr' %}

{% set qoses = salt['pillar.get']('slurm:acct:qos', {}) %}

{% for qos, qosinfo in qoses|dictsort %}

{% set absent = qosinfo.pop('absent', False) %}

{% if absent %}

slurm_qos_delete_{{qos}}:
  cmd.run:
    - name: {{ sacctmgr }} -i delete qos {{ qos }}
    - unless: test -z "`{{ sacctmgr }} -n show qos {{ qos }}`"
    - require:
        - pkg: slurm_client

{% else %}


slurm_qos_create_{{qos}}:
  cmd.run:
    - name: {{ sacctmgr }} -i create qos {{ qos }}
    - unless: test -n "`{{ sacctmgr }} -n show qos {{ qos }}`"
    - require:
        - pkg: slurm_client

{% for attr, val in qosinfo|dictsort %}

slurm_qos_set_{{qos}}_{{attr}}:
  cmd.run:
    - name: {{ sacctmgr }} -i modify qos {{ qos }} set {{attr}}={{val}}
    - unless: test "`{{ sacctmgr }} -n -P show qos {{ qos }} format={{attr}}`" = "{{val}}"
    - require:
        - cmd: slurm_qos_create_{{qos}}

{% endfor %}       {# Iterating over parameters for this QOS #}

{% endif %}        {# not absent #}

{% endfor %}       {# Iterating over all QOSs #}


