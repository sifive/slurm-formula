## SLURM state for setting up clusters

{% from "slurm/map.jinja" import slurm with context %}
include:
  - slurm
  - slurm.logdir

{% set sacctmgr = 'sacctmgr' %}

{% set clusters = salt['pillar.get']('slurm:acct:clusters', {}) %}

## Get the state for all clusters
{% for cluster, exists in clusters|dictsort %}


{% if exists %}

slurm_cluster_create_{{cluster}}:
  cmd.run:
    - name: {{ sacctmgr }} -i create cluster {{ cluster }}
    - unless: test -n "`{{ sacctmgr }} -n show cluster {{ cluster }}`"
    - require:
        - pkg: slurm_client

{% else %}

slurm_cluster_delete_{{cluster}}:
  cmd.run:
    - name: {{ sacctmgr }} -i delete cluster {{ cluster }}
    - unless: test -z "`{{ sacctmgr }} -n show cluster {{ cluster }}`"
    - require:
        - pkg: slurm_client


{% endif %}        {# not absent #}

{% endfor %}       {# Iterating over all clusters #}


