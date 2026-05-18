---
description: "Task list template — Clean Environment Segurança preset"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`

**Prerequisites**: plan.md (required), spec.md (required for user stories e Security Impact),
threat-model.md (recomendado), research.md, data-model.md, contracts/

> **Preset ativo:** `clean-environment-seguranca-core`. Cada user story gera, além das tasks
> funcionais, um bloco de tasks `[SEC]` transversais derivadas dos Gates aprovados no `plan.md`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Pode rodar em paralelo (arquivos diferentes, sem dependências)
- **[Story]**: User story a que pertence (US1, US2, ...) ou `SEC` se transversal de segurança
- **[SEC]**: Task de segurança derivada de Cláusula da Constituição
- Incluir caminhos exatos de arquivos

## Path Conventions

Veja `plan.md → Project Structure` para a estrutura adotada.

---

## Phase 1: Setup (Shared Infrastructure)

- [ ] T001 Criar estrutura de pastas conforme plan.md
- [ ] T002 Inicializar projeto com [framework] + dependências
- [ ] T003 [P] Configurar linting, formatter e tipagem

### Phase 1 — Segurança (Clean Environment Preset)

- [ ] T001-SEC1 Executar `/speckit.security-setup` (instala .gitignore, .env.example, husky, git-secrets, security-check.sh, secrets fortes via openssl) — **bloqueante**
- [ ] T001-SEC2 Verificar `.specify/memory/security-context.md` resolvido e versionado
- [ ] T001-SEC3 Confirmar que `.specify/memory/constitution.md` foi gerado pelo preset

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: Nenhuma user story começa até esta fase estar completa.

- [ ] T004 Schema do banco + migrations
- [ ] T005 [P] Framework de autenticação/autorização (middleware base)
- [ ] T006 [P] Estrutura de API routing + middlewares globais
- [ ] T007 Modelos base que todas as stories dependem
- [ ] T008 Error handling e logger estruturado
- [ ] T009 Configuration management via env vars

### Phase 2 — Segurança (Clean Environment Preset)

- [ ] T004-SEC1 Conexão de banco sob TLS em produção; usuário aplicativo com permissões mínimas (Cláusula III.7)
- [ ] T005-SEC1 Middleware `authenticate()` lê HttpOnly cookie e valida assinatura (Cláusulas I.1, I.5)
- [ ] T005-SEC2 Middleware `authorize(resource)` verifica `req.user.id === resource.userId` E roles (Cláusula I.5)
- [ ] T006-SEC1 Middleware `rateLimit()` configurado por tier (auth: 5/15min; público: 100/min; user-scoped: 1000/h) (Cláusula I.4)
- [ ] T006-SEC2 Middleware `securityHeaders()` injeta HSTS, CSP, X-Frame-Options, nosniff, Referrer-Policy (Cláusula III.3)
- [ ] T006-SEC3 CORS configurado a partir de `ALLOWED_ORIGINS` env var (whitelist) (Cláusula III.4)
- [ ] T008-SEC1 Error handler retorna mensagens opacas; stack trace só em log estruturado (Cláusula III.1)
- [ ] T008-SEC2 Logger remove/hash campos sensíveis automaticamente (allowlist de campos seguros) (Cláusula III.2)
- [ ] T009-SEC1 Validar que toda config sensível vem de env var, zero hardcoded; bloquear secrets em VITE_/NEXT_PUBLIC_

**Checkpoint**: Fundação pronta — user stories podem começar em paralelo

---

<!--
  ============================================================================
  Para CADA user story (Phase 3, 4, ...) o /speckit.tasks gera:
   - Tasks funcionais (T010, T011, ...)
   - Bloco "Segurança (transversal, da Constitution)" com tasks T0NN-SEC1, -SEC2, ...
  Os exemplos abaixo são ilustrativos. Substituir conforme as user stories reais.
  ============================================================================
-->

## Phase 3: User Story 1 — [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description]

### Implementação

- [ ] T010 [P] [US1] Modelo de dados em src/models/[Entity].ts
- [ ] T011 [US1] Validação de input (Zod schema) em src/api/[endpoint]/schema.ts
- [ ] T012 [US1] Endpoint POST /api/[recurso] em src/api/[endpoint]/route.ts
- [ ] T013 [US1] Endpoint GET /api/[recurso]/:id em src/api/[endpoint]/[id]/route.ts
- [ ] T014 [P] [US1] Componente frontend em src/components/[Feature].tsx

### Segurança (transversal, da Constitution)

- [ ] T010-SEC1 [US1] Campos sensíveis do modelo marcados (classification: PII/financial/health/credential) e tratados conforme plan.md
- [ ] T011-SEC1 [US1] Schema de validação rejeita strings > limite, arrays > limite, profundidade JSON > limite (Cláusula II.5)
- [ ] T011-SEC2 [US1] Schema usa whitelist de valores quando aplicável (Cláusula II.3)
- [ ] T012-SEC1 [US1] Endpoint POST aplica `authenticate()` + `authorize()` (Cláusula I.5)
- [ ] T012-SEC2 [US1] Endpoint POST aplica `rateLimit(tier='user-scoped')` (Cláusula I.4)
- [ ] T012-SEC3 [US1] Banco escrito apenas via ORM/prepared statement (Cláusula II.2)
- [ ] T012-SEC4 [US1] Erros retornam mensagem opaca; logs sem PII (Cláusulas III.1, III.2)
- [ ] T012-SEC5 [US1] Audit log entry gerada se feature toca PII (Cláusula IV.8)
- [ ] T013-SEC1 [US1] Endpoint GET valida ownership do recurso (Cláusula I.5)
- [ ] T013-SEC2 [US1] Paginação obrigatória; campos retornados em whitelist
- [ ] T014-SEC1 [US1] Frontend não usa `dangerouslySetInnerHTML` para input de usuário; se necessário, DOMPurify (Cláusula II.4)
- [ ] T014-SEC2 [US1] Frontend lê estado de auth via cookie HttpOnly (`credentials: 'include'` em fetch); zero leitura de token no JS (Cláusula I.1)

### Testes — Test-First (Cláusula V.1)

- [ ] T015 [P] [US1] Contract tests para POST /api/[recurso]
- [ ] T016 [P] [US1] Contract tests para GET /api/[recurso]/:id
- [ ] T017 [P] [US1] Test-First — testes ESCREVEM PRIMEIRO, código depois (Constitution Art. III do Spec Kit)

### Testes adversariais (transversal, da Constitution)

- [ ] T015-SEC1 [US1] Teste: requisição sem cookie → 401
- [ ] T015-SEC2 [US1] Teste: requisição com cookie de outro usuário → 403 (IDOR)
- [ ] T015-SEC3 [US1] Teste: input com payload XSS → escapado/sanitizado
- [ ] T015-SEC4 [US1] Teste: input com payload SQLi → query parametrizada absorve sem efeito
- [ ] T015-SEC5 [US1] Teste: estouro de rate limit → 429
- [ ] T015-SEC6 [US1] Teste: payload acima do limite → 413
- [ ] T015-SEC7 [US1] Teste: header de segurança presente em toda resposta

**Checkpoint US1**: feature funcional + tasks `[SEC]` completas + testes verdes = MVP entregável independentemente.

---

## Phase 4: User Story 2 — [Title] (Priority: P2)

[Mesma estrutura — Implementação, Segurança (transversal), Testes, Testes adversariais]

---

## Phase N: Polish & Cross-cutting

- [ ] T0NN Documentação OpenAPI/Swagger atualizada
- [ ] T0NN [P] Testes E2E
- [ ] T0NN [P] Performance / load tests

### Phase N — Segurança (Pré-deploy)

- [ ] T0NN-SEC1 `npm audit --audit-level=high` zero CRÍTICAS/ALTAS (Cláusula V.6)
- [ ] T0NN-SEC2 Source maps desligados em produção
- [ ] T0NN-SEC3 `/speckit.security-audit` executado em modo full; relatório anexado em `security-audit.md`
- [ ] T0NN-SEC4 Checklist de pré-deploy (do `checklist-template.md` deste preset) revisado
- [ ] T0NN-SEC5 Plan de rollback documentado
- [ ] T0NN-SEC6 [Se LGPD/GDPR] Política de privacidade e termos revisados
- [ ] T0NN-SEC7 Monitoring (Sentry/equivalente), alertas e centralização de logs ativados
- [ ] T0NN-SEC8 Rotação de secrets de produção confirmada (não os de dev)

---

## Resumo das tasks de segurança

Total de tasks `[SEC]` desta feature: **[gerado automaticamente]**
Cláusulas constitucionais cobertas: **[lista de cláusulas, gerado automaticamente]**
Riscos OWASP cobertos: **[lista, derivada da seção Security & Privacy Impact da spec]**
