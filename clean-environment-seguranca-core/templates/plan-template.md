# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]

**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

> **Preset ativo:** `clean-environment-seguranca-core`. Os Security Gates e Compliance
> Gates abaixo são derivados dos seis artigos da Constituição (`constitution.md`) e do
> arquivo `.specify/memory/security-context.md`. Não é permitido passar para Phase 0 sem
> que cada gate esteja com decisão registrada (passa / justificado em Complexity Tracking).

---

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

---

## Technical Context

**Language/Version**: [e.g., Python 3.11, Node 20, Go 1.22 ou NEEDS CLARIFICATION]

**Primary Dependencies**: [e.g., FastAPI, NestJS, Spring Boot ou NEEDS CLARIFICATION]

**Storage**: [e.g., PostgreSQL 15, MongoDB, Redis ou N/A]

**Testing**: [e.g., pytest, Jest, Vitest ou NEEDS CLARIFICATION]

**Target Platform**: [e.g., Linux server, AWS Lambda, Vercel Edge]

**Project Type**: [e.g., web-service, library, CLI, mobile-app]

**Performance Goals**: [domínio-específico: req/s, p95 latency, etc.]

**Constraints**: [domínio-específico: orçamento, footprint, offline-capable]

**Scale/Scope**: [usuários esperados, LOC, telas]

---

## Security Context Resolution

> Lido de `.specify/memory/security-context.md`. Se ausente ou incompleto, o hook
> `before_plan` da extension `clean-environment-seguranca-tools` bloqueia este comando.

| Campo | Valor resolvido |
| --- | --- |
| `project_type` | [SaaS B2B / SaaS B2C / E-commerce / Fintech / Healthtech / Interno / MVP / Outro] |
| `criticality` | [CRÍTICO / ALTO / MÉDIO / BAIXO] |
| `compliance.lgpd` | [true / false] |
| `compliance.gdpr` | [true / false] |
| `compliance.pci_dss` | [true / false] |
| `compliance.hipaa` | [true / false] |
| `compliance.outros` | [lista ou vazio] |
| `auth_strategy` | [JWT em cookie / Session / OAuth / SAML / WebAuthn / outro] |
| `stack.frontend` | [...] |
| `stack.backend` | [...] |
| `stack.database` | [...] |
| `stack.cloud` | [...] |

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Phase -1: Pre-Implementation Gates

#### Simplicity Gate (Spec Kit base)
- [ ] Usando ≤3 projetos?
- [ ] Sem future-proofing especulativo?

#### Anti-Abstraction Gate (Spec Kit base)
- [ ] Usando framework diretamente?
- [ ] Representação única de cada modelo?

#### Integration-First Gate (Spec Kit base)
- [ ] Contracts definidos?
- [ ] Contract tests escritos antes da implementação?

#### Security Gate — Artigo I (Identidade e Acesso)
- [ ] Token de sessão em HttpOnly cookie (Cláusula I.1) — N/A se feature pública sem sessão
- [ ] Hash de senha bcrypt cost ≥ 12 ou argon2id (Cláusula I.2) — N/A se feature não toca senhas
- [ ] Comparação timing-safe em credenciais (Cláusula I.3)
- [ ] Rate limiting configurado para endpoints sensíveis (Cláusula I.4)
- [ ] Autenticação E autorização verificadas (Cláusula I.5)
- [ ] IDs opacos (UUID/ULID) em recursos sensíveis (Cláusula I.6)
- [ ] Mensagens não revelam existência de identificador (Cláusula I.7) — N/A se feature não trata auth
- [ ] 2FA para criticidade ≥ ALTA ou operações admin (Cláusula I.8) — `{{ if criticality in [ALTO,CRÍTICO] }}` obrigatório

#### Security Gate — Artigo II (Integridade de Dados)
- [ ] Validação de input com schema explícito no backend (Cláusula II.1)
- [ ] Parametrização absoluta em queries (Cláusula II.2)
- [ ] Whitelist em filtros, MIME types, redirects, CORS (Cláusula II.3)
- [ ] Sanitização contextual (HTML/URL/JS) — sem `dangerouslySetInnerHTML` sem DOMPurify (Cláusula II.4)
- [ ] Limites explícitos em strings/arrays/uploads (Cláusula II.5)
- [ ] Upload validado por magic bytes (Cláusula II.6) — N/A se feature não tem upload
- [ ] Webhook/integração externa com integridade verificada (Cláusula II.7) — N/A se não aplicável

#### Security Gate — Artigo III (Resiliência e Operação)
- [ ] Erros opacos para clientes (Cláusula III.1)
- [ ] Logs estruturados sem PII (Cláusula III.2)
- [ ] Headers de segurança (HSTS, CSP, X-Frame-Options, nosniff, Referrer-Policy) (Cláusula III.3)
- [ ] CORS com whitelist (Cláusula III.4)
- [ ] Timeouts e circuit breakers em chamadas externas (Cláusula III.5)
- [ ] HTTPS forçado + HSTS (Cláusula III.6)
- [ ] Banco com permissões mínimas + TLS em produção (Cláusula III.7)
- [ ] Soft delete por padrão para recursos auditáveis (Cláusula III.8) — N/A se hard delete justificado

#### Compliance Gate — Artigo IV
> Ativações automáticas conforme `security_context.compliance.*`.

##### `{{ if compliance.lgpd }}` LGPD ativa
- [ ] Minimização de dados aplicada (Cláusula IV.2)
- [ ] Base legal documentada para cada finalidade desta feature (Cláusula IV.3)
- [ ] Endpoints/processos de direitos do titular (acesso, retificação, exclusão, portabilidade) definidos (Cláusula IV.4)
- [ ] Playbook de incidente referenciado, notificação 72h prevista (Cláusula IV.5)
- [ ] Audit log para operações sobre PII (Cláusula IV.8)

##### `{{ if compliance.gdpr }}` GDPR ativa
- [ ] DPO declarado em `security-context.md`
- [ ] Base legal sob GDPR Art. 6 documentada
- [ ] Direitos do titular sob GDPR Cap. III implementados
- [ ] Registro de atividades de tratamento (RoPA) atualizado

##### `{{ if compliance.pci_dss }}` PCI-DSS ativa
- [ ] PAN nunca armazenado (Cláusula IV.6)
- [ ] Tokenização via provedor certificado configurada
- [ ] Escopo PCI minimizado documentado

##### `{{ if compliance.hipaa }}` HIPAA ativa
- [ ] Criptografia at-rest e in-transit configurada (Cláusula IV.7)
- [ ] Audit log imutável de acessos a PHI
- [ ] BAA (Business Associate Agreement) ou equivalente firmado com fornecedores que processam PHI

#### Cultura e Processo Gate — Artigo V
- [ ] Plano de testes Test-First para endpoints de segurança (Cláusula V.1)
- [ ] Defesa em profundidade prevista (Cláusula V.2)
- [ ] Pre-commit hooks instalados (`/speckit.security-setup` executado) (Cláusula V.5)
- [ ] Renovate/Dependabot ativo no repositório (Cláusula V.6)

---

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
├── threat-model.md      # (opcional) gerado por /speckit.threat-model
├── security-audit.md    # (opcional) gerado por /speckit.security-audit
└── tasks.md             # Phase 2 output (NÃO criado por /speckit.plan)
```

### Source Code (repository root)

```text
# Escolha UMA estrutura e remova as outras opções

# Option 1: Single project
src/
├── models/
├── services/
├── api/
└── lib/
tests/
├── contract/
├── integration/
├── unit/
└── security/        # NOVO — testes adversariais (IDOR, SQLi, XSS, replay)

# Option 2: Web application
backend/
├── src/
│   ├── models/
│   ├── services/
│   ├── api/
│   └── middleware/  # auth, rate-limit, audit-log
└── tests/
frontend/
├── src/
└── tests/

# Option 3: Mobile + API (igual à 2, com pasta ios/ ou android/)
```

**Structure Decision**: [Documentar a escolha e referenciar diretórios reais]

---

## Phase 0: Research

[Pesquisar e resolver todos os `NEEDS CLARIFICATION` da spec e do Technical Context. Para cada
escolha de tech stack, documentar rationale, alternativas consideradas, riscos de segurança.]

Output: `research.md`

---

## Phase 1: Design

1. **Data model**: entidades, relacionamentos, **classificação de sensibilidade** por campo.
2. **Contracts**: API spec (OpenAPI), schemas de evento, schemas de webhook. Cada endpoint
   declara: auth required (sim/não), roles permitidas, rate limit, validação esperada, formato
   de erro.
3. **Quickstart**: cenários de validação que cobrem **tanto** funcional **quanto** segurança
   (ex.: tentar acessar recurso de outro usuário e verificar 403).
4. **Security cross-checks**: re-executar o Constitution Check após o design. Mudanças exigem
   nova passagem.

Output: `data-model.md`, `quickstart.md`, `contracts/`

---

## Phase 2: Tasks generation

(Não executado por `/speckit.plan` — é responsabilidade do `/speckit.tasks`.)

Após este plan ser aprovado, executar `/speckit.tasks` para gerar `tasks.md`. As tasks `[SEC]`
serão geradas automaticamente a partir das Cláusulas marcadas como aplicáveis nos Gates acima.

---

## Complexity Tracking

> **Preencha ESTA tabela somente se algum gate acima foi marcado como "Justificado"
> em vez de "Passa".**

| Cláusula violada | Justificativa | Mitigação compensatória | Aprovado por |
| --- | --- | --- | --- |
| [ex: III.8 — soft delete] | [Feature exige hard delete por LGPD direito ao esquecimento] | [Backup imutável anterior; audit log da exclusão] | [Security Champion @nome] |

Toda linha desta tabela **deve** ter `Aprovado por` preenchido por um Security Champion antes
de `/speckit.implement` poder ser executado. O hook `before_implement` valida.

---

## Próximas etapas

Após este plan estar aprovado:

1. (Opcional, recomendado) `/speckit.threat-model` — gera STRIDE da feature.
2. `/speckit.tasks` — quebra em tasks de implementação + tasks `[SEC]` transversais.
3. `/speckit.analyze` — consistência cruzada spec/plan/tasks.
4. `/speckit.security-audit` (modo design) — análise das decisões de plan antes do código.
5. `/speckit.implement` — executa as tasks. Hook `after_implement` roda `security-check.sh`.
