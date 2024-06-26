# Leihs Deploy

This repository contains code to deploy a Leihs system.


## Configuring the Deploy - Ansible Variables for Installing Leihs

The important configuration is [defaults.yml](./defaults.yml). It should never
be necessary to modify this file.

We have set up the deployment such that variables defined in this file have the
lowest precedence possible in an Ansible setup. They are precicely __role defaults__.
See the [Ansible documentation regarding precedence](ansible-docs-precedence) for details.

All variables defined in you inventory (including those from an inventory file) can and will override variables defined in [defaults.yml](./defaults.yml)!


## Requirements

A recent Linux or MacOS System with "build-tools" installed.

The scripts used in this project try to setup their own environment via the
_asdf_ version manager. Therefore `asdf` needs to be properyly installed and
configured, see https://asdf-vm.com/.


## Warning

We assume that the target server is used exclusively to run Leihs. We further
assume that the system is a largely unmodified Debian or Ubuntu server. If this
is true the integrity and security of the system will not be compromised to our
best knowledge.

## Project-local `ansible` installation

To use `ansible` locally installed and pinned to a recommended version,
use the helper scripts to set up a "python virtualenv" and use it from there.

For simple use, invoke the wrapper script: `bin/ansible-playbook --help`
To debug the installation (more verbose output): `bin/virtualenv`


[ansible-docs-precedence]: https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#understanding-variable-precedence
