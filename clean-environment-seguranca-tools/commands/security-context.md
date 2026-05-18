---
description: "Captura interativa do contexto de segurança do projeto. Gera .specify/memory/security-context.md, que alimenta os Compliance Gates do plan-template e os hooks before_plan da extension."
handoffs:
  - label: "Gerar Constituição"
    agent: speckit.constitution
    prompt: "Gere a constitution do projeto usando o security-context recém-criado."
  - label: "Executar Security Setup"
    agent: speckit.security-setup
    prompt: "Instale .gitignore, .env.example, scripts e hooks."
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty). Argumentos opcionais
podem incluir hints como `--type=fintech --critical` para acelerar a Q&A.

## Outline

Você é a skill `speckit-security-context` da Clean Environment. Sua responsabilidade é
**capturar** o contexto de segurança do projeto através de Q&A guiada e **gerar** o arquivo
`.specify/memory/security-context.md` com todas as seções preenchidas. Este arquivo é a fonte
de verdade que os templates do preset `clean-environment-seguranca-core` consultam para ativar
gates condicionais.

### Pré-execução

1. Verifique se `.specify/memory/security-context.md` já existe.
   - Se existe e está completo (sem `NEEDS CLARIFICATION`): pergunte ao usuário se quer **atualizar** (modo edição) ou **substituir** (recomeçar do zero).
   - Se existe mas tem `NEEDS CLARIFICATION`: entre em modo de completamento, foque nas seções pendentes.
   - Se não existe: modo criação completa.
2. Confirme que `.specify/memory/` existe (`mkdir -p` se não).

### Execução — Q&A em 8 fases

Conduza a conversa em fases. **Não despeje todas as perguntas de uma vez.** Espere resposta a cada bloco antes de seguir. Use as próprias respostas para refinar perguntas posteriores (ex.: se "tipo = e-commerce", já sugira PCI-DSS como prováveis).

#### Fase 1 — Identificação

Pergunte:

- Nome do projeto.
- Identificador curto (slug, ex.: `pagamentos-v2`).
- Tech lead responsável (email).
- Security Champion designado (email).
- Repositório (URL do GitHub privado).
- Versão do contexto (sugira `1.0.0`).

#### Fase 2 — Tipo de projeto

Pergunte (single choice):

- SaaS B2B
- SaaS B2C
- E-commerce
- Marketplace
- Fintech
- Healthtech
- Edtech
- Rede social
- Ferramenta interna
- MVP / Prova de conceito
- Outro (capturar descrição)

#### Fase 3 — Usuários e escala

Pergunte:

- Público-alvo (internet pública / clientes B2B / usuários internos / parceiros).
- Volume esperado (faixas: < 1.000 / 1.000–10.000 / 10.000–100.000 / > 100.000).
- Geografia dos usuários (Brasil / Europa / EUA / global). **Use isso para inferir LGPD/GDPR como provável.**

#### Fase 4 — Dados tratados

Pergunte (multi-select, marque tudo que se aplica):

- PII básica (nome, email)
- PII sensível (CPF, RG, endereço, telefone, data de nascimento)
- Documentos digitalizados
- Dados financeiros (transações, contas)
- Dados de pagamento (PAN/CVV) — **se sim, alerte que PCI-DSS é obrigatório**
- Dados de saúde (PHI) — **se sim, alerte que HIPAA ou equivalente é obrigatório**
- Dados biométricos
- Localização em tempo real
- Comunicações privadas
- Conteúdo gerado por usuário
- Credenciais (passwords, API keys, tokens)

Para cada categoria marcada, pergunte volume estimado (alta/média/baixa cardinalidade).

#### Fase 5 — Compliance

Combinando respostas das fases 3 e 4, **sugira** o conjunto de compliance aplicável e confirme com o usuário:

- LGPD (Brasil) — sugira `true` se geografia inclui Brasil OU dados pessoais tratados
- GDPR (Europa) — sugira `true` se geografia inclui Europa OU dados pessoais de europeus
- PCI-DSS — sugira `true` se dados de pagamento marcados
- HIPAA — sugira `true` se dados de saúde marcados E geografia inclui EUA
- SOC 2 — pergunte se há venda para enterprises americanas
- ISO 27001 — pergunte se há requisito contratual
- Outros (capturar descrição livre)

#### Fase 6 — Stack técnico

Pergunte (estruture como tabela):

- Frontend (framework, versão)
- Backend (linguagem, framework, versão)
- Banco de dados primário
- Cache (Redis/equivalente)
- Queue/messaging
- Storage (S3/equivalente)
- Email service
- Monitoring (Sentry/Datadog/equivalente)
- Cloud provider
- Deployment target (Vercel/AWS/GCP/Azure/on-prem)
- CI/CD platform

#### Fase 7 — Autenticação

Pergunte:

- Estratégia primária (Email+Password / OAuth Google / OAuth Github / OAuth Microsoft / SAML SSO / Magic Link / WebAuthn/Passkeys / SAML Enterprise / outro)
- Suporte a múltiplos provedores
- Session storage (HttpOnly cookie — **default constitucional**)
- Refresh tokens? (sim/não)
- 2FA — política: **obrigatório se criticidade ≥ ALTA ou se houver acesso admin**
- 2FA — método (TOTP/SMS/WebAuthn/email magic link)

#### Fase 8 — Criticidade e riscos

Pergunte:

- Nível de criticidade (CRÍTICO / ALTO / MÉDIO / BAIXO). Sugira automaticamente:
  - CRÍTICO se: dados financeiros OU saúde OU > 100k usuários OU dados biométricos.
  - ALTO se: dados pessoais OU B2B com alta dependência operacional.
  - MÉDIO se: interno OU B2B com baixa criticidade.
  - BAIXO se: MVP/POC explicitamente.
- Riscos OWASP prováveis (pré-marque os mais comuns para o tipo de projeto):
  - E-commerce: A01, A02, A03, A04, A05, A07
  - Fintech: A01, A02, A03, A04, A07, A08, A09
  - Healthtech: A01, A02, A04, A07, A08, A09
  - SaaS B2B: A01, A03, A04, A05, A07
  - Rede social: A01, A03, A04, A05, A07, A10
- Vetores específicos preocupantes (texto livre).

### Geração do arquivo

Após coletar tudo, **gere** `.specify/memory/security-context.md` exatamente neste esquema (substitua os valores reais e mantenha YAML frontmatter para parse pelos templates):

```markdown
---
schema_version: "1.0"
generated_by: "speckit.security-context"
generated_at: "[ISO 8601 timestamp]"
preset: "clean-environment-seguranca-core"
extension: "clean-environment-seguranca-tools"

project:
  name: "[Nome]"
  slug: "[slug]"
  repo: "[URL]"
  tech_lead: "[email]"
  security_champion: "[email]"
  version: "1.0.0"

type: "[saas_b2b|saas_b2c|ecommerce|marketplace|fintech|healthtech|edtech|social|internal|mvp|other]"
type_description: "[apenas se 'other']"

users:
  audience: "[public|b2b|internal|partners]"
  volume_estimate: "[<1k|1k-10k|10k-100k|>100k]"
  geographies: ["BR", "EU", ...]

data:
  pii_basic: true|false
  pii_sensitive: true|false
  documents: true|false
  financial: true|false
  payment_card: true|false
  health_phi: true|false
  biometric: true|false
  location_realtime: true|false
  private_messages: true|false
  user_generated_content: true|false
  credentials: true|false

compliance:
  lgpd: true|false
  gdpr: true|false
  pci_dss: true|false
  hipaa: true|false
  soc2: true|false
  iso27001: true|false
  others: ["..."]
  dpo_contact: "[email do DPO se LGPD/GDPR]"

stack:
  frontend: "[...]"
  backend: "[...]"
  database: "[...]"
  cache: "[...]"
  queue: "[...]"
  storage: "[...]"
  email: "[...]"
  monitoring: "[...]"
  cloud: "[...]"
  deployment: "[...]"
  cicd: "[...]"

auth:
  strategy: "[email_password|oauth_google|oauth_github|oauth_microsoft|saml|magic_link|webauthn|...]"
  session_storage: "httponly_cookie"  # padrão constitucional
  refresh_tokens: true|false
  mfa_required: true|false
  mfa_methods: ["totp", "webauthn", ...]

criticality: "[CRITICAL|HIGH|MEDIUM|LOW]"

owasp_focus:
  - "A01"
  - "A03"
  - "..."

specific_threats:
  - "[texto livre]"

incident_response:
  internal_contact: "[email]"
  security_email: "[email]"
  phone: "[opcional]"
---

# Security Context — [Nome do Projeto]

[Resumo executivo em prosa, 2-3 parágrafos, que explica em linguagem natural o que foi capturado. Útil para humanos lendo o arquivo.]

## Princípios não-negociáveis herdados

Toda feature deste projeto adere automaticamente aos 6 artigos da Constituição
(`.specify/memory/constitution.md`):

- Artigo I — Identidade e Acesso
- Artigo II — Integridade dos Dados
- Artigo III — Resiliência e Operação
- Artigo IV — Privacidade e Compliance (com os compliance gates ativos acima)
- Artigo V — Cultura e Processo
- Artigo VI — Governança e Evolução

## Decisões registradas nesta captura

[Lista breve das decisões importantes tomadas durante a Q&A, com data. Útil para auditoria posterior.]

## Próximos passos

1. `/speckit.constitution` — gera a constitution já com compliance condicional resolvido
2. `/speckit.security-setup` — instala .gitignore, .env.example, scripts e hooks
3. `/speckit.specify <descrição>` — primeira feature
```

### Pós-execução

Após escrever o arquivo:

1. Mostre um resumo em prosa do que foi capturado (5-8 linhas).
2. Confirme com o usuário se as escolhas de compliance estão corretas (esta é a única que tem **alto custo de errar**).
3. Avise que `/speckit.constitution` agora deve ser executado a seguir.
4. Se algum item ficou `NEEDS CLARIFICATION` (usuário não soube responder), liste explicitamente e avise: "o hook `before_plan` da extension vai bloquear `/speckit.plan` até que estes itens sejam resolvidos. Re-execute /speckit.security-context quando tiver as respostas."
