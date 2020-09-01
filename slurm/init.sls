## SLURM common config

{% from "slurm/map.jinja" import slurm with context %}


## The default Ubuntu 16.04 version of munge breaks because of permissions
## on /var/log/.  We have to override this with --force at service startup
## time.  We need to install this before the package as the package
## tries to start itself.

{% if grains.os=='Ubuntu' and grains.osrelease=='16.04' %}
slurm_munge_service_config:
  file.managed:
    - name: /etc/systemd/system/munge.service
    - user: root
    - group: root
    - mode: '0644'
    - source: salt://slurm/files/munge.service
    - require_in:
        - pkg: slurm_munge_pkg
{% endif %}
    
slurm_munge_pkg:
  pkg.installed:
    - names: {{ slurm.munge_pkgs|yaml }}
{% if slurm.munge_version is defined %}
    - version: {{ slurm.munge_version }}
{% endif %}

slurm_munge_key64:
  file.managed:
    - name: /etc/munge/munge.key64
    - user: munge
    - group: munge
    - mode: '0400'
    - contents_pillar: slurm:MungeKey64
    - require:
        - pkg: slurm_munge_pkg

slurm_munge_key:
  cmd.wait:
    - name: base64 -d /etc/munge/munge.key64 >/etc/munge/munge.key
    - watch:
        - file: slurm_munge_key64
  file.managed:
    - name: /etc/munge/munge.key
    - require:
        - cmd: slurm_munge_key
    - replace: false
    - mode: '0400'
    - require_in:
      - service: slurm_munge_service

slurm_munge_service:
  service.running:
    - name: munge
    - enable: true
{% if salt['pillar.get']('slurm:restart:munge', False) %}
    - watch:
      - cmd: slurm_munge_key
{% endif %}
    - require:
      - pkg: slurm_munge_pkg
    - require:
      - file: slurm_munge_key
    - require_in:
      - pkg: slurm_client

{% if slurm.user_create|default(False) == True %}
slurm_user:
  user.present:
    - name: slurm
    - system: True
{% if slurm.homedir is defined %}
    - home: {{ slurm.user_homedir }}
{% endif %}
{% if slurm.user_uid is defined %}
    - uid: {{ slurm.user_uid }}
{% endif %}
{% if slurm.user_gid is defined %}
    - gid: {{ slurm.user_gid }}
{% else %}
    - gid_from_name: True
{% endif %}
    - require_in:
        - pkg: slurm_client
        - file: slurm_topology
        - file: slurm_cgroup
        - file: slurm_config_energy
{% endif %}

slurm_client:
  pkg.installed:
    - names: {{ slurm.client_pkgs|yaml }}
{% if slurm.slurm_version is defined %}
    - version: {{ slurm.slurm_version }}
{% endif %}

slurm_config:
  file.managed:
    - name: {{slurm.etcdir}}/slurm.conf
    - user: slurm
    - group: root
    - mode: '0644'
    - template: jinja
    - source: salt://slurm/files/slurm.conf.jinja
    - context:
        slurm: {{ slurm }}



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

