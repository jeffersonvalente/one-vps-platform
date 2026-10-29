# Um VPS barato virado plataforma privada de engenharia

## O problema

Trabalho com múltiplos clientes em paralelo. Cada um tem credenciais, identidade git, ambiente de desenvolvimento e contexto separado. Tudo isso vivia no mesmo PC: memória disputada, risco de commit com identidade errada, nada acessível fora de casa.

Além disso, qualquer servidor de desenvolvimento exposto à internet vira superfície de ataque. A maioria das soluções resolve um problema e cria outro.

## O que foi construído

Uma plataforma de engenharia privada rodando num único VPS de 16 GB, onde:

- Cada cliente tem um usuário Linux próprio, home `0700`, identidade git isolada — commit no repositório errado é impossível
- Nada está exposto à internet: SSH, ingress e APIs escutam só na interface Tailscale
- TLS válido com Let's Encrypt via DNS-01 — o desafio é um registro DNS, não uma porta aberta
- k3s + ArgoCD para orquestração e GitOps: tudo que roda é um commit
- SigNoz compartilhado com dados tagueados por `service.name` e `deployment.environment`
- Um cliente precisa de Docker Compose: rootless Docker escopado ao usuário, sem conflito com containerd

Terraform provisiona VPS, DNS, ACLs do Tailscale e bucket de estado. Ansible configura o host, usuários, k3s, Docker e backup. ArgoCD sincroniza as aplicações. Do zero ao stack completo: cerca de 30 minutos.

## Decisões técnicas

**Tailscale em vez de VPN tradicional** — zero configuração de firewall, zero porta exposta, funciona em qualquer rede sem ajuste.

**k3s em vez de k8s full** — single-node, menos overhead, suficiente para o escopo. A lógica de GitOps é idêntica.

**Um usuário Linux por cliente** — mais simples e mais seguro do que RBAC em camada de aplicação. O isolamento é garantido pelo SO, não por política.

**SigNoz em vez de stack Prometheus+Grafana** — traz métricas, logs e traces num único serviço, com menos peças pra manter.

**SOPS com age** — secrets versionados no Git, descriptografados só em tempo de execução, sem depender de serviço externo.

## Resultado

| Antes | Depois |
|---|---|
| 79% de RAM antes de abrir qualquer lab | PC a 60% com jogo AAA rodando, sessão de trabalho viva no servidor |
| Três identidades GitHub atrás de um `gh login` | Um usuário Linux por cliente, commit no repo errado impossível |
| Nada acessível fora de casa | Laptop, celular, qualquer lugar na tailnet |
| Setup em `%AppData%` e scripts manuais | `rebuild.sh` — do sistema operacional fresco ao stack completo em ~30min |
| Zero observabilidade do homelab | SigNoz com traces distribuídos, métricas e logs por ambiente |

1 incidente registrado em produção: ZooKeeper OOMKilled sob carga. 35 minutos do alerta ao fix. Postmortem em `docs/decisions/`.

## Repositório

[github.com/jeffersonvalente/one-vps-platform](https://github.com/jeffersonvalente/one-vps-platform)
