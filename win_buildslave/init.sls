{% from 'win_buildslave/map.jinja' import win_buildslave with context %}

{% for pkg in win_buildslave.packages %}
wbs_pkg_{{ pkg }}:
  pkg.installed:
    - name: {{ pkg }}
{% endfor %}

{% for pkg in win_buildslave.choco_packages %}
wbs_choco_pkg_{{ pkg }}:
  chocolatey.installed:
    - name: {{ pkg }}
{% endfor %}

wbs_install_pywin32:
  cmd.script:
    - name: install_pywin32.ps1
    - source: salt://win_buildslave/files/install_pywin32.ps1
    - shell: powershell

wbs_user:
  user.present:
    - name: {{ win_buildslave.user }}
    - password: {{ win_buildslave.user_password }}
    - fullname: BuildBot slaves

wbs_user_setup:
  cmd.script:
    - name: service_user.ps1 {{ win_buildslave.user }} {{ win_buildslave.user_password }} {{ win_buildslave.root_directory }}
    - source: salt://win_buildslave/files/service_user.ps1
    - shell: powershell

# TODO: allow custom buildbot code
# NOTE: no virtualenv support
wbs_pip_buildslave:
  pip.installed:
    - name: buildbot-slave

wbs_root:
  file.directory:
    - name: {{ win_buildslave.root_directory }}
    - user: {{ win_buildslave.user }}
    - makedirs: true

{% set roots = [] %}
{% for name, slave in win_buildslave.slaves.items() %}
{% set root = slave.get('root', win_buildslave.root_directory + '/' + slave.user + '/' + name) %}
{% do roots.append(root) %}
buildslave_{{ name }}_root:
  file.directory:
    - name: {{ root }}
    - user: {{ win_buildslave.user }}
    - makedirs: true

buildslave_{{ name }}_create:
  cmd.run:
    - name: 'cd C:\ && buildslave create-slave {{ root }} {{ slave.master }} {{ slave.name | default(name) }} {{ slave.password }}'
#    - cwd: {{ root | yaml_encode }}
    - runas: {{ win_buildslave.user }}
    - password: {{ win_buildslave.user_password }}
    - creates: '{{ root }}/buildbot.tac'
{% endfor %}

wbs_service_key:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\BuildBot'

wbs_service_key_perms:
  cmd.script:
    - name: setup_svc_reg_perms.ps1 {{ win_buildslave.user }} {{ win_buildslave.user_password }}
    - source: salt://win_buildslave/files/setup_svc_reg_perms.ps1
    - shell: powershell
    - onchanges:
      - reg: wbs_service_key

wbs_service_params:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\BuildBot\Parameters'
    - vname: directories
    - vdata: {{ roots | join(';') }}

wbs_service_setup:
  cmd.script:
    - name: service.ps1 {{ win_buildslave.user }} {{ win_buildslave.user_password }}
    - source: salt://win_buildslave/files/service.ps1
    - shell: powershell
