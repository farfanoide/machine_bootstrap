Pyenv + Python
==============

Simple role to install homebrew python, pyenv and some python versions via pyenv

Requirements
------------

None

Role Variables
--------------

```yml
pyenv_enabler: /tmp/pyenvenabler
pyenv_path: "{{ ansible_env.HOME }}/.pyenv"
pyenv_default_python:  2.7.10
pyenv_default_pythons: [ "{{pyenv_default_python}}" ]
pip_env:
  PIP_REQUIRE_VIRTUALENV: ''
```

Dependencies
------------

None
