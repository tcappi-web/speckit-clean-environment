# Feature Specification: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`

**Created**: [DATE]

**Status**: Draft

**Input**: User description: "$ARGUMENTS"

> **Preset ativo:** `clean-environment-seguranca-core` — a seção *Security & Privacy Impact*
> abaixo é **obrigatória** e alimenta os Security/Compliance Gates do `plan.md`.

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.

  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### Edge Cases

- What happens when [boundary condition]?
- How does system handle [error scenario]?
- What happens under [adversarial input]?

---

## Security & Privacy Impact *(mandatory — Clean Environment Preset)*

<!--
  Esta seção é OBRIGATÓRIA. Ela é lida pelo /speckit.plan para ativar os Security Gates
  e Compliance Gates, pelo /speckit.threat-model para gerar o modelo STRIDE, e pelo
  /speckit.security-audit para focar a auditoria.

  Se algum item estiver marcado como [NEEDS CLARIFICATION], o hook before_plan BLOQUEIA
  /speckit.plan até que seja resolvido.
-->

### Dados tratados nesta feature

Marque TODOS os tipos que se aplicam. Use `[NEEDS CLARIFICATION]` se a feature
descrita não permitir determinar:

- [ ] Apenas dados públicos (não há PII envolvida)
- [ ] PII básica (nome, email)
- [ ] PII sensível (CPF, RG, endereço, telefone, data de nascimento)
- [ ] Credenciais (senha, token, chave de API)
- [ ] Dados financeiros (cartão, conta bancária, transações)
- [ ] Dados de pagamento (PAN, CVV — exige PCI-DSS no security-context)
- [ ] Dados de saúde (PHI — exige HIPAA ou equivalente no security-context)
- [ ] Dados biométricos
- [ ] Localização em tempo real
- [ ] Comunicações privadas (mensagens, anexos)
- [ ] Conteúdo gerado por usuário (texto, mídia)
- [ ] Logs/audit trails com PII por consequência

### Operações sobre os dados

- [ ] Leitura (GET, listagem, busca)
- [ ] Criação (POST)
- [ ] Atualização (PUT/PATCH)
- [ ] Exclusão (DELETE — qual tipo: soft ou hard?)
- [ ] Exportação/portabilidade
- [ ] Compartilhamento com terceiros (qual?)

### Permissões necessárias

- [ ] Público (sem autenticação)
- [ ] Usuário autenticado (qualquer)
- [ ] Apenas dono do recurso
- [ ] Apenas membros do mesmo tenant/organização
- [ ] Apenas admin (role específica)
- [ ] Roles customizadas: ___________

### Riscos OWASP aplicáveis (Top 10 2021)

Marque TODOS que se aplicam à superfície desta feature. O `/speckit.threat-model` vai
expandir cada um marcado em vetores de ataque concretos.

- [ ] **A01 — Broken Access Control** (IDOR, escalação de privilégio, force browsing, JWT misuse)
- [ ] **A02 — Cryptographic Failures** (criptografia ausente/fraca em PII, senhas, tokens, sessão, comunicação)
- [ ] **A03 — Injection** (SQL, NoSQL, command, LDAP, XPath, template, ORM)
- [ ] **A04 — Insecure Design** (falhas de threat modeling, fluxos sem revisão, suposições inseguras)
- [ ] **A05 — Security Misconfiguration** (defaults inseguros, verbose errors, configs expostas, CORS/headers)
- [ ] **A06 — Vulnerable and Outdated Components** (dependências, libs, runtime, OS)
- [ ] **A07 — Identification and Authentication Failures** (sessão, MFA, password policy, recuperação)
- [ ] **A08 — Software and Data Integrity Failures** (CI/CD comprometido, deserialização insegura, integridade de update)
- [ ] **A09 — Security Logging and Monitoring Failures** (falta de logs, logs com PII, falta de detecção)
- [ ] **A10 — Server-Side Request Forgery (SSRF)** (URLs vindas do cliente, integrações com webhooks)

### Compliance específico desta feature

> Lido do `.specify/memory/security-context.md`. Marque overrides para esta feature se aplicar
> compliance ADICIONAL ao do projeto (ex.: projeto LGPD geral, mas esta feature processa cartão
> e precisa PCI-DSS adicional).

- [ ] LGPD aplica (herda do projeto: [LGPD_PROJECT_STATE])
- [ ] GDPR aplica (herda: [GDPR_PROJECT_STATE])
- [ ] PCI-DSS aplica (herda: [PCI_PROJECT_STATE]) — esta feature adiciona? [ ]
- [ ] HIPAA aplica (herda: [HIPAA_PROJECT_STATE]) — esta feature adiciona? [ ]
- [ ] Outro: ___________

### Base legal para tratamento (se LGPD/GDPR ativo)

Por finalidade, declarar a base legal:

| Finalidade | Base legal | Observação |
| --- | --- | --- |
| [ex: cadastro de usuário] | [Consentimento / Execução de contrato / Obrigação legal / ...] | |

### Dados que sairão dos limites da Clean Environment

- [ ] Nenhum
- [ ] Enviados a provedor: ___________ (qual? sob qual contrato?)
- [ ] Recebidos de provedor: ___________ (validação de origem?)
- [ ] Trafegam por integrações públicas: ___________

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST [specific capability]
- **FR-002**: System MUST [specific capability]
- **FR-003**: Users MUST be able to [key interaction]

*Example of marking unclear requirements:*

- **FR-NNN**: System MUST authenticate users via [NEEDS CLARIFICATION: auth method not specified — email/password, SSO, OAuth?]

### Security Requirements *(derived from Constitution + Security & Privacy Impact)*

> Esta subseção é gerada/expandida automaticamente a partir das marcações da seção acima.
> O `/speckit.tasks` vai materializar cada SR como tasks `[SEC]`.

- **SR-001**: Token de sessão **deve** ser armazenado em HttpOnly cookie (Constitution I.1).
- **SR-002**: Toda escrita em banco **deve** usar parametrização (Constitution II.2).
- **SR-003**: Rate limiting **deve** estar configurado para [endpoints específicos da feature].
- **SR-004**: Logs desta feature **não devem** conter [listar PII envolvida da seção acima].
- **SR-005**: [Adicionar SRs específicas conforme riscos OWASP marcados]

### Key Entities *(include if feature involves data)*

- **[Entity 1]**: [What it represents, key attributes, classificação de sensibilidade]
- **[Entity 2]**: [What it represents, relationships, retenção]

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: [Measurable metric — funcional]
- **SC-002**: [Measurable metric — performance]
- **SC-SEC-001**: Zero achados de severidade CRÍTICA na execução do `/speckit.security-audit` desta feature.
- **SC-SEC-002**: 100% das SRs cobertas por testes automatizados (Cláusula V.1).
- **SC-SEC-003**: [Se LGPD/GDPR] Endpoints de exercício de direitos do titular operacionais antes do release.

---

## Assumptions

- [Assumption sobre usuários]
- [Assumption sobre escopo]
- **Security assumption**: o `.specify/memory/security-context.md` reflete fielmente o contexto do projeto. Discrepância detectada exige atualização do contexto antes desta feature ir para implementação.

---

## Out of Scope

- [O que esta feature explicitamente NÃO entrega]
- [Itens de segurança adiados para próxima feature, COM justificativa]

---

## Review & Acceptance Checklist

### Content Quality

- [ ] Foco em usuário e negócio, não em implementação
- [ ] User stories priorizadas e independentemente testáveis
- [ ] Edge cases identificados

### Requirement Completeness

- [ ] Nenhum marker `[NEEDS CLARIFICATION]` remanescente
- [ ] Requirements testáveis e não-ambíguos
- [ ] Success criteria mensuráveis

### Security & Privacy Completeness *(Clean Environment Preset)*

- [ ] Todos os tipos de dados marcados (inclusive "apenas público" se for o caso)
- [ ] Permissões declaradas
- [ ] Riscos OWASP marcados (todos que aplicam, não só "obviamente"; A01 e A03 são quase sempre relevantes)
- [ ] Compliance herdado do projeto + overrides desta feature
- [ ] Base legal declarada para cada finalidade (se LGPD/GDPR)
- [ ] Dados que saem da empresa identificados
- [ ] SRs incluem cobertura para os riscos OWASP marcados
- [ ] SC-SEC-* incluídos
