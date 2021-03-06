## SLURM common config used by DB and other

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
    - user: munge
    - group: munge
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

{% if slurm.user_create|default(False) == True %}

slurm_group:
  group.present:
    - name: {{ slurm.slurm_group }}
    - system: True
{% if slurm.user_gid is defined %}
    - gid: {{ slurm.user_gid }}
{% endif %}
    - require_in:
        - user: slurm_user

slurm_user:
  user.present:
    - name: {{ slurm.slurm_user }}
    - system: True
    - home: /nonexistent
    - createhome: false
    - shell: /bin/false
{% if slurm.user_uid is defined %}
    - uid: {{ slurm.user_uid }}
{% endif %}
{% if slurm.user_gid is defined %}
    - gid: {{ slurm.user_gid }}
{% else %}
    - gid_from_name: True
{% endif %}

{% endif %}

slurm_etcdir:
  file.directory:
    - name: {{slurm.etcdir}}
    - user: root
    - group: root
    - mode: '0755'



## Lock down package versions (currently only on Debian)

{% if slurm.slurm_version is defined and slurm.aptprefdir is defined %}

slurm_aptpref_slurm:
  file.managed:
    - name: {{slurm.aptprefdir}}/50-slurm.pref
    - template: jinja
    - source: salt://slurm/files/apt.pref.jinja
    - context:
        pkgs: {{ (slurm.client_pkgs + slurm.db_pkgs + slurm.pam_pkgs + slurm.devel_pkgs + slurm.db_devel_pkgs + slurm.openlava_pkgs) | yaml }}
        version: {{ slurm.slurm_version }}
        priority: '2000'
    - user: 'root'
    - group: 'root'
    - mode: '0644'

{% endif %}
