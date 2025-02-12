# Leihs Deploy

This repository contains code to deploy a Leihs system. It is based on Ansible.

![Deploy Diagram](deploy.svg)

## Example

    ./bin/ansible-playbook -i inventories/local-vm/host deploy_play.yml

## Configuring the Deploy - Ansible Variables for Installing Leihs

The important configuration is [defaults.yml](./defaults.yml). It should never
be necessary to modify this file.

We have set up the deployment such that variables defined in this file have the
lowest precedence possible in an Ansible setup. They are precicely __role defaults__.
See the [Ansible documentation regarding precedence](ansible-docs-precedence) for details.

All variables defined in you inventory (including those from an inventory file)
can and will override variables defined in [defaults.yml](./defaults.yml)!


## Requirements


### On the Deploy / Control Machine

A recent Linux or MacOS System with "build-tools" installed. If you are
deploying from a Debian or Ubuntu system, we recommend to install the following
packages:

* build-essential
* bzip2
* git
* libffi-dev
* libncurses5-dev
* libncursesw5-dev
* libpq-dev
* libreadline-dev
* libsqlite3-dev
* libssl-dev
* python3-dev
* ruby
* ruby-dev
* shared-mime-info
* zlib1g-dev

The scripts used in this project try to setup their own environment via the
_asdf_ version manager. Therefore `asdf` needs to be properyly installed and
configured, see https://asdf-vm.com/.


### Requirements on the Target System (Leihs Server)

As target systems we support recent Versions of Debian and Ubuntu LTS. The user
on the control machine needs access to the target system as root via SSH.


We assume that the target server is used exclusively to run Leihs. We further
assume that the system is a largely unmodified Debian or Ubuntu server. If this
is true the integrity and security of the system will not be compromised to our
best knowledge.

