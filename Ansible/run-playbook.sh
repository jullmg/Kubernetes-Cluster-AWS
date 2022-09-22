#!/bin/sh

clear
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i inventory --user ubuntu playbook.yaml
