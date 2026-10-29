.PHONY: help tf-init tf-plan tf-apply ansible-base ansible-all argocd rebuild lint

help:
	@grep -E '^[a-z-]+:' Makefile | sed 's/:.*//' | sort

TF_DIRS := terraform/hostinger terraform/cloudflare terraform/tailscale terraform/oci

tf-init:
	@for d in $(TF_DIRS); do (cd $$d && terraform init -upgrade); done

tf-plan:
	@for d in $(TF_DIRS); do (cd $$d && terraform plan); done

tf-apply:
	@for d in $(TF_DIRS); do (cd $$d && terraform apply); done

ansible-base:
	cd ansible && ansible-playbook playbooks/base.yml playbooks/tailscale.yml

ansible-all:
	cd ansible && ansible-playbook site.yml

argocd:
	scripts/bootstrap-argocd.sh

rebuild:
	scripts/rebuild.sh

lint:
	@for d in $(TF_DIRS); do (cd $$d && terraform fmt -check && terraform validate); done
	cd ansible && ansible-lint || true
