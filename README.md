# Homelab Infrastructure

A Terraform-based repository for deploying and managing my homelab infrastructure. This project automates the provisioning of various components, making it easier to maintain and scale your home network environment.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Commands](#commands)

## Overview

This repository contains Terraform code and related scripts to provision a homelab environment. The main objectives of this project are:

- **Automation:** Streamline the deployment of infrastructure components.
- **Scalability:** Allow easy scaling and modifications as needs change.
- **Reproducibility:** Provide a clear and reproducible infrastructure setup.

## Architecture

My homelab infrastructure is composed of Mikrotik Routers and Minisforums MiniPCs.
There is a few assumptions made in the hardware. You can find more details about setting up the [network hardware](./docs/setting_up_network.md)
and [compute nodes](./docs/setting_up_nodes.md).

## Prerequisites

Before you begin you must of met the following requirements.
* Terraform (version 1.10 or higher)
* Python3
* Ansible (version 2.16 or higher)

## Commands

Deploying terraform infrastructure.
```shell
# Format the terraform hcl
terraform -chdir=deploy/terraform fmt

# Plan the infrastructure changes
terraform -chdir=deploy/terraform plan

# Apply the infrastructure changes
terraform -chdir=deploy/terraform apply
```

Running the ansible scripts. Ensure the ssh key you are using has access to the proxmox nodes.
```shell
# Lint the ansible scripts
ansible-lint ./deploy/ansible/homelab.yaml

# Run the ansible scripts
ansible-playbook -i ./deploy/ansible/inventory ./deploy/ansible/homelab.yaml --key-file ~/.ssh/id_ed25519_homelab
```
