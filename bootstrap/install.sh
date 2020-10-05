#!/usr/bin/env bash

set -eou pipefail

# TODO: automatically update the ~/.kube/config with required context generated.
# KUBECONFIG=~/.kube/config:~/projects/k8s-install/ansible/playbooks/output/k8s-config.yaml kubectl config view --flatten > ~/.kube/config

if [[ ! $(gotk) ]]; then
  echo "gotk needs to be installed - https://toolkit.fluxcd.io/get-started/#install-the-toolkit-cli"
  exit 1
fi

# Untaint master nodes
# TODO: Enable Ansible to allow configuring the taints to be added/removed.
[[ ! $(kubectl taint nodes --all node-role.kubernetes.io/master-) ]] && echo "Masters untainted"

# Check the cluster meets the fluxv2 prerequisites
[[ $(gotk check --pre) -ne 0 ]] && echo "Prerequisites were not satisfied" && exit 1

gotk install \
  --version=latest \
  --components=source-controller,kustomize-controller,helm-controller,notification-controller \
  --namespace=gitops-system \
  --arch=arm64

if [[ -f .secrets/k8s-secret-fluxcd-ssh.yaml ]]; then
  echo "Applying existing sealed-secret key"
  kubectl apply -f .secrets/k8s-secret-sealed-secret-private-key.yaml
fi

if [[ -f bootstrap/repo.yaml ]]; then
  echo "Applying Repo Sync"
  kubectl apply -f bootstrap/repo.yaml
fi
