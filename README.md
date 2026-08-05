# Desafio AWS & DevOps

Aplicação full-stack de demonstração: um botão em React chama uma API Node.js, que lê uma
mensagem de uma base de dados PostgreSQL e regista cada clique como evento (log estruturado
+ contador na base de dados) e como métrica custom no CloudWatch (`ChallengeApp/ButtonClicks`).

Infraestrutura 100% em Terraform, deploy em Amazon EKS, CI/CD com GitHub Actions
(autenticação OIDC, sem credenciais AWS no repositório), TLS terminado no ALB e
observabilidade no CloudWatch com alarme de cliques notificado por SNS.

## Arquitetura

```text
Browser ──HTTPS──> ALB (ACM) ──/api/*──> api ×2 (Node+TS) ──> RDS PostgreSQL (subnets privadas)
                        │                  │
                        └──/──> frontend ×2 (nginx+React)    ├──PutMetricData──> CloudWatch ──> Alarm ──> SNS (email)
                                                             └──logs JSON──> CloudWatch Logs (retenção 14d)
GitHub Actions ──OIDC──> IAM role (push ECR + deploy no namespace app)
Secrets Manager ──External Secrets Operator──> Secret db-credentials (namespace app)
```

## Stack

- **Frontend**: React 18 + TypeScript + Vite + Tailwind, servido por nginx
- **API**: Node.js + Express + TypeScript (`GET /api/message`, `GET /health`)
- **Base de dados**: PostgreSQL 16 (container local, Amazon RDS em produção)
- **Infra**: Terraform (módulos `vpc`, `eks`, `rds`, `iam`, `ecr`, `observability`)
- **K8s**: Amazon EKS + Kustomize, 2 réplicas da API e do frontend, probes no `/health`
- **CI/CD**: GitHub Actions, build e push para ECR, deploy com kustomize/kubectl

## Estrutura

```text
app/
  frontend/           React + Vite + TS, Dockerfile multi-stage (nginx)
  api/                Node + Express + TS, Dockerfile multi-stage (dist)
deploy/
  docker-compose.yml  ambiente local (frontend + api + postgres)
  k8s/bootstrap/      namespace, RBAC do pipeline e ClusterSecretStore (aplicado uma vez, como admin)
  k8s/base/           recursos da app (deployments, services, ingress, ExternalSecret)
  k8s/overlays/prod/  overlay prod (imagens ECR)
terraform/
  modules/            vpc, eks, rds, iam, ecr, observability
  envs/prod/          composição dos módulos + bootstrap helm (ALB controller, ESO) + ACM
.github/workflows/    ci.yml (testes) e cd.yml (build, push, deploy)
```

## 1. Quickstart local (Docker)

```bash
cd aws-devops-challenge/deploy && docker compose up --build
```

Abrir http://localhost:8080 e clicar no botão. A API fica em http://localhost:3000
(`/health` e `/api/message`). As credenciais do compose servem apenas para desenvolvimento
local; em produção a password é gerada pelo Terraform (`random_password`) e vive apenas no
Secrets Manager e no state do Terraform.

## 2. Testes

API (Jest + Supertest):

```bash
cd aws-devops-challenge/app/api && npm install && npm test
```

Frontend (Vitest + Testing Library):

```bash
cd aws-devops-challenge/app/frontend && npm install && npm test
```

## 3. Deploy na AWS

Pré-requisitos: Terraform >= 1.6, AWS CLI autenticada com permissões de administração
(apenas para correr o Terraform; a aplicação e o pipeline usam roles mínimos), kubectl e
Docker. Editar `terraform/envs/prod/terraform.tfvars` (`github_org`, `github_repo`,
`alarm_email`) e depois:

```bash
cd aws-devops-challenge/terraform/envs/prod && terraform init && terraform apply
```

O apply (15 a 20 minutos) cria: VPC com subnets públicas/privadas em 2 AZs, cluster EKS
com node group gerido e add-ons (incluindo Pod Identity e CloudWatch Observability),
repositórios ECR, RDS PostgreSQL em subnets privadas, secret no Secrets Manager, roles IAM
de privilégio mínimo, log groups com retenção de 14 dias, tópico SNS + alarme de cliques,
certificado self-signed importado no ACM, e instala via Helm o AWS Load Balancer Controller
e o External Secrets Operator.

Passo manual único e inevitável: confirmar a subscrição do SNS no email (a AWS não permite
automatizar a confirmação). Tudo o resto é infra como código.

### Primeiro deploy da aplicação

Obter os outputs, configurar o kubectl e substituir o ARN do certificado no Ingress:

```bash
cd aws-devops-challenge/terraform/envs/prod && terraform output
```

```bash
aws eks update-kubeconfig --name desafio-eks --region eu-south-2
```

Substituir `REPLACE_WITH_ACM_CERT_ARN` em `deploy/k8s/base/ingress.yaml` pelo valor de
`acm_certificate_arn` e `000000000000` em `deploy/k8s/overlays/prod/kustomization.yaml`
pelo ID da conta. Aplicar primeiro o bootstrap (namespace, RBAC do pipeline e
ClusterSecretStore), uma única vez, com credenciais de administrador:

```bash
cd aws-devops-challenge/deploy/k8s/bootstrap && kubectl apply -k .
```

E depois a aplicação:

```bash
cd aws-devops-challenge/deploy/k8s/overlays/prod && kubectl apply -k .
```

Para imagens iniciais sem pipeline, fazer login, build, tag e push:

```bash
aws ecr get-login-password --region eu-south-2 | docker login --username AWS --password-stdin <CONTA>.dkr.ecr.eu-south-2.amazonaws.com && cd aws-devops-challenge/app/api && docker build -t <CONTA>.dkr.ecr.eu-south-2.amazonaws.com/desafio/api:latest . && docker push <CONTA>.dkr.ecr.eu-south-2.amazonaws.com/desafio/api:latest && cd ../frontend && docker build -t <CONTA>.dkr.ecr.eu-south-2.amazonaws.com/desafio/frontend:latest . && docker push <CONTA>.dkr.ecr.eu-south-2.amazonaws.com/desafio/frontend:latest
```

Obter o endereço público HTTPS:

```bash
kubectl -n app get ingress app
```

Abrir `https://<ADDRESS>` (o browser avisa sobre o certificado self-signed, o que é
esperado; ver secção TLS abaixo). HTTP na porta 80 faz redirect para HTTPS.

## 4. CI/CD (GitHub Actions)

Secrets e variables a configurar no repositório (Settings > Secrets and variables > Actions):

| Tipo     | Nome                  | Valor                                    |
|----------|-----------------------|------------------------------------------|
| Secret   | `AWS_ROLE_ARN`        | output `github_actions_role_arn`         |
| Variable | `AWS_REGION`          | `eu-south-2`                             |
| Variable | `EKS_CLUSTER_NAME`    | `desafio-eks`                            |
| Variable | `ACM_CERTIFICATE_ARN` | output `acm_certificate_arn`             |

- **ci.yml** (PRs e pushes): typecheck e testes da API e do frontend.
- **cd.yml** (push em `main`): assume o role via OIDC (sem access keys), faz build e push
  das duas imagens para o ECR com tag do SHA do commit, atualiza o kustomize, substitui o
  ARN do certificado no Ingress, faz `kubectl apply -k` e aguarda o rollout das 2 réplicas.

O role do GitHub só pode autenticar no ECR, fazer push nas duas imagens e descrever o
cluster. Dentro do EKS, um access entry mapeia o role para o grupo `deployers`, cuja
RoleBinding se limita ao namespace `app`: faz deploy da aplicação, não administra a conta.
Por isso o pipeline aplica apenas `k8s/overlays/prod`; os recursos de bootstrap (namespace,
RBAC, ClusterSecretStore) são aplicados uma vez à mão por um administrador, nunca pelo CI.

## 5. TLS

O ALB termina TLS com um certificado self-signed importado no ACM (criado pelo Terraform em
`envs/prod/acm.tf`), porque o desafio dispensa domínio próprio e o ALB exige certificados
do ACM. O listener 80 faz redirect para 443 (`ssl-redirect` no Ingress).

**Em produção**: registar ou transferir o domínio para uma hosted zone do Route53, pedir um
certificado público no ACM com validação por DNS (registo CNAME criado automaticamente pelo
Terraform via `aws_acm_certificate_validation`), criar um record A alias para o ALB e apontar
o `certificate-arn` do Ingress para esse certificado. A renovação é automática e o browser
deixa de mostrar aviso.

## 6. Observabilidade e demo do alarme

- Logs da API (JSON estruturado via pino) e do sistema são enviados pelo add-on CloudWatch
  Observability para `/aws/containerinsights/desafio-eks/application` (mais `host` e
  `dataplane`); os logs do plano de controlo ficam em `/aws/eks/desafio-eks/cluster`.
  Todos com retenção de 14 dias.
- Pesquisa de eventos de clique e erros no Logs Insights:

```text
fields @timestamp, event, totalClicks, err.message
| filter event = "button_click" or level >= 50
| sort @timestamp desc
```

- Cada clique incrementa `ChallengeApp/ButtonClicks` (dimensão `Service=api`) via
  `PutMetricData`, permitido ao pod da API apenas nesse namespace.
- **Demo do alarme**: clicar no botão mais de 10 vezes num minuto. O alarme
  `desafio-button-clicks-spike` passa a ALARM e o SNS envia email; ao abrandar, volta a OK
  e chega o email de resolução. Para um demo mais rápido, baixar `clicks_threshold` no
  tfvars (por exemplo 5).

## 7. Custos e teardown

EKS + NAT Gateway + ALB + RDS custam cerca de $4 a $5 por dia. Hábito recomendado durante o
desenvolvimento: destruir ao fim de cada sessão e recriar no dia seguinte.

```bash
cd aws-devops-challenge/terraform/envs/prod && terraform destroy
```

## Decisões de arquitetura

| Decisão | Escolha | Justificação |
|---------|---------|--------------|
| Base de dados | RDS PostgreSQL em subnets privadas | Serviço gerido, credenciais automáticas no Secrets Manager; Postgres em container fica só no docker-compose local |
| TLS sem domínio | Self-signed importado no ACM | O ALB só aceita certs ACM; demonstra terminação TLS real sem comprar domínio |
| Identidade dos pods | EKS Pod Identity | Mesmo efeito que IRSA sem gerir OIDC provider por cluster |
| Métrica de cliques | `PutMetricData` + logs JSON | Demonstra IAM mínimo; logs permitem pesquisa de eventos e erros |
| Secrets no K8s | External Secrets Operator | Sincroniza o secret da DB para um Secret nativo; a API lê só o seu secret |
| Manifests | Kustomize | Nativo do kubectl, overlays por ambiente |
| Módulos Terraform | terraform-aws-modules para VPC e EKS | Módulos auditados; rds, iam, ecr e observability escritos à mão |
| Backend do state | local, com S3+DynamoDB documentado | Em produção: state remoto com locking (comentado em `versions.tf`) |

## Checklist do desafio

- [x] 1. App web: botão, API, PostgreSQL, evento por clique, `/health`, containers
- [x] 2. Infraestrutura em Terraform, recriável sem configurações manuais
- [x] 3. Cluster Amazon EKS com node group e add-ons
- [x] 4. Deploy no Kubernetes: ECR, 2 réplicas, probes, Ingress, frontend-api-db ligados
- [x] 5. Repositório GitHub com todo o código e instruções
- [x] 6. CI/CD GitHub Actions: testes, build, push ECR, deploy; sem credenciais no repo
- [x] 7. TLS no ALB com ACM + explicação da solução de produção
- [x] 8. Logs e métricas no CloudWatch, pesquisáveis, retenção 14 dias
- [x] 9. Alarme de cliques com notificação SNS (email), demonstrável ao vivo
- [x] 10. Secrets no Secrets Manager, lidos apenas pelo que precisa deles
- [x] 11. IAM de privilégio mínimo (GitHub, pods, agentes), sem AdministratorAccess
