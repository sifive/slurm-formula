## SLURM state for setting up clusters

{% from "slurm/map.jinja" import slurm with context %}
include:
  - slurm
  - slurm.logdir

{% set sacctmgr = 'sacctmgr' %}

{% set clusters = salt['pillar.get']('slurm:acct:clusters', {}) %}

## Get the state for all clusters
{% for cluster, clusterinfo in clusters|dictsort %}

{% set absent = clusterinfo.pop('absent', False) %}

{% if absent %}

slurm_cluster_delete_{{cluster}}:
  cmd.run:
    - name: {{ sacctmgr }} -i delete cluster {{ cluster }}
    - unless: test -z "`{{ sacctmgr }} -n show cluster {{ cluster }}`"
    - require:
        - pkg: slurm_client

{% else %}

slurm_cluster_create_{{cluster}}:
  cmd.run:
    - name: {{ sacctmgr }} -i create cluster {{ cluster }}
    - unless: test -n "`{{ sacctmgr }} -n show cluster {{ cluster }}`"
    - require:
        - pkg: slurm_client

{% for attr, val in clusterinfo|dictsort %}

slurm_cluster_set_{{cluster}}_{{attr}}:
  cmd.run:
    - name: {{ sacctmgr }} -i modify cluster {{ cluster }} set {{attr}}={{val}}
    - unless: test "`{{ sacctmgr }} -n -P show cluster {{ cluster }} format={{attr}}`" = "{{val}}"
    - require:
        - cmd: slurm_cluster_create_{{cluster}}

{% endfor %}       {# Iterating over parameters for this cluster #}

{% endif %}        {# not absent #}

{% endfor %}       {# Iterating over all clusters #}


