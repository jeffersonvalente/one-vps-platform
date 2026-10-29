# one-vps-platform

**Uma VPS barata transformada em plataforma de engenharia privada para vários clientes, sem nada exposto na internet.**

Acesso só por Tailscale, um usuário Linux por cliente, k3s + ArgoCD, observabilidade compartilhada, Docker rootless onde um tenant precisa. Tudo é Terraform + Ansible + GitOps; uma máquina zerada vira plataforma funcionando em cerca de 30 minutos.

[English](README.md) · Português

![License: MIT](https://img.shields.io/badge/license-MIT-green) ![Terraform](https://img.shields.io/badge/Terraform-1.6+-7B42BC?logo=terraform&logoColor=white) ![Ansible](https://img.shields.io/badge/Ansible-2.17+-EE0000?logo=ansible&logoColor=white) ![k3s](https://img.shields.io/badge/Kubernetes-k3s-326CE5?logo=kubernetes&logoColor=white) ![Tailscale](https://img.shields.io/badge/rede-s%C3%B3%20Tailscale-000?logo=tailscale)

## Resultado

| Antes (um PC Windows) | Depois (VPS de 16 GB + o PC como terminal) |
|---|---|
| 79 % de RAM em uso antes de abrir um lab sequer | PC em 60 % **com um jogo AAA rodando**; a sessão de trabalho continua viva no servidor |
| Três identidades GitHub atrás de um único `gh login` | Um usuário Linux por cliente, home `0700`, identidade git própria, commit na empresa errada é impossível |
| Nada acessível fora da mesa | Notebook, celular, qualquer lugar da tailnet; a internet vê **zero** portas TCP abertas |
| Setup vivia no `%AppData%` | `scripts/rebuild.sh` → SO zerado até plataforma completa em ~30 min |
| | 19 % de RAM ocioso com a stack inteira; **44 %** sob um teste de carga com 14 serviços OpenTelemetry |
| | 1 incidente (ZooKeeper OOM sob carga), 35 min, causa raiz e correção no [postmortem](docs/decisions/0004-incident-signoz-zookeeper-oom.md) |

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/assets/architecture-dark.svg">
  <img src="docs/assets/architecture-light.svg" width="900" alt="Architecture: laptop and phone reach the VPS only through a Tailscale mesh; the internet sees no open TCP port. Inside the VPS: one Linux user per tenant (client-a with rootless Docker, client-b, personal with kubeconfig, ops), a single-node k3s with ingress-nginx and cert-manager via DNS-01, ArgoCD core syncing from this repo, and a shared SigNoz split by tenant attributes. Provisioned by Terraform, Ansible and SOPS; only restic backups and DNS-01 challenges leave the box.">
</picture>

## O que resolve

| Problema | Como |
|---|---|
| Trabalho de clientes, projetos pessoais e jogos disputando a mesma máquina | O trabalho vai pra VPS; o PC só desenha pixels (VS Code Remote-SSH) |
| Credenciais de clientes sem relação lado a lado | Um usuário Linux por tenant, sem sudo, identidade `gh`/git própria, home que ninguém mais lê |
| Servidor de dev que também é superfície de ataque pública | Não é público. Malha Tailscale; SSH, API server e ingress escutam só na interface da tailnet |
| TLS válido para hosts que a internet não alcança | cert-manager com Let's Encrypt **DNS-01**: o desafio é um registro DNS, não uma porta aberta |
| Um tenant precisa de `docker compose`; a máquina roda k3s | Docker **rootless** restrito a esse usuário; daemon root mascarado; sem conflito com o containerd |
| Uma stack de observabilidade, vários tenants | SigNoz compartilhado; dados marcados por `service.name` / `deployment.environment`; service accounts por tenant (viewer pro runtime, editor pra automação) |
| "Funciona no meu servidor" | Tudo é commit: Terraform (VPS, DNS, ACL do Tailscale, bucket), Ansible (host, usuários, k3s, docker, backup), ArgoCD (`k8s/apps/`), SOPS pros segredos |

## Como funciona

```
terraform/      hostinger (só import, destroy cancelaria o plano) · cloudflare · tailscale · oci
ansible/        base → tailscale → users → k3s → docker-rootless → backup      (site.yml roda tudo)
k8s/            bootstrap/argocd (core + app-of-apps) · apps/ (ingress-nginx, cert-manager, signoz)
scripts/        bootstrap-argocd.sh · rebuild.sh
docs/           ARCHITECTURE.md · decisions/ (ADRs + postmortem) · inventory.md · client/ssh_config.example
```

Bootstrap em uma linha: o provedor entrega um Ubuntu zerado → `terraform apply` → `ansible-playbook site.yml` → Tailscale no ar → **fecha a porta 22 no provedor** → `scripts/bootstrap-argocd.sh` → apps sincronizam do Git. Runbook completo, orçamento de memória e manhas do SigNoz: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) (em inglês).

## Decisões

ADRs curtos, um por escolha que alguém poderia questionar (em inglês):

- [0001, VPS alugada em vez de servidor em casa](docs/decisions/0001-vps-instead-of-homelab.md)
- [0002, k3s single-node + ArgoCD core](docs/decisions/0002-k3s-and-argocd-core.md)
- [0003, um usuário Linux por tenant](docs/decisions/0003-one-linux-user-per-tenant.md)
- [0004, incidente: SigNoz parou de ingerir (ZooKeeper OOMKilled)](docs/decisions/0004-incident-signoz-zookeeper-oom.md)

## Use

Clone, copie os arquivos `*.example`, preencha seus IDs, gere uma chave `age` pro SOPS e siga o runbook. Assume uma VPS KVM da Hostinger, DNS na Cloudflare e uma conta Tailscale, mas cada parte específica de provedor é um módulo Terraform fino que dá pra trocar.

## Licença

MIT.
