---
description: "Auditoria de segurança OWASP + Constitution. Modos: design (spec/plan/tasks sem código), full (varre código), delta (apenas mudanças desde último commit/sessão). Consulta knowledge/vulnerabilities.md. Produz specs/<feature>/security-audit.md."
handoffs:
  - label: "Implementar com Findings Resolvidos"
    agent: speckit.implement
    prompt: "Implemente o plano após auditoria. Findings críticos devem estar resolvidos."
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --paths-only
  ps: scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly
---

## User Input

```text
$ARGUMENTS
```

Argumentos:
- `--mode=design|full|delta` (default lê de config, fallback `design`)
- `--target=<paths>` (em modo full/delta: foca em paths específicos)
- `--block-on=critical|high|medium` (default lê de config, fallback `critical`)
- `--no-block` (apenas reporta, não bloqueia)

## Outline

Você é a skill `speckit-security-audit` da Clean Environment. Sua responsabilidade é
**varrer** o estado atual do projeto (artefatos de design e/ou código), **identificar**
findings de segurança consultando a knowledge base e a Constituição, **produzir** um
relatório estruturado em `specs/<feature_directory>/security-audit.md`, e **retornar**
um exit code interpretável pelo hook `before_implement` que bloqueia `/speckit.implement`
quando há findings de severidade ≥ ao threshold configurado.

### Pré-execução

1. Determine modo (default `design` via config, override por `--mode`).
2. Determine threshold de bloqueio (default `critical`).
3. Leia obrigatórios:
   - `.specify/memory/security-context.md`
   - `.specify/memory/constitution.md`
   - `knowledge/vulnerabilities.md` (da extension)
4. Leia conforme modo:
   - **design**: `spec.md`, `plan.md`, `threat-model.md` (se existir), `tasks.md` (se existir), `contracts/`, `data-model.md`.
   - **full**: tudo de design + código-fonte completo (respeita `.gitignore`).
   - **delta**: tudo de design + `git diff <base>..HEAD` (base default = último merge para main).

### Execução — modo design

Análise sem código. Foca em **decisões de arquitetura**:

#### Categoria A — Aderência constitucional

Para **cada** das 36 cláusulas (Artigos I a VI), verifique se a decisão de plan/tasks é compatível. Liste como conformes, justificadas (em Complexity Tracking), ou pendentes.

#### Categoria B — Cobertura de ameaças

Para cada `THR-NNN` em `threat-model.md`, verifique se há mitigação refletida no plan.md (Project Structure, middlewares, contratos) e tasks `[SEC]` correspondentes em tasks.md.

#### Categoria C — Compliance gates

Re-valide cada Compliance Gate do `plan.md` à luz do `security-context.md`. Detecta inconsistências: ex.: spec marca dados financeiros mas plan.md não tem gate PCI-DSS preenchido.

#### Categoria D — Riscos não declarados

Para cada `Key Entity` em data-model.md, infira riscos OWASP prováveis e verifique se foram marcados na spec.

#### Categoria E — Suposições frágeis

Analise `Assumptions` da spec e `Constraints` do plan procurando suposições de segurança implícitas (ex.: "usuários têm conexão estável" — relevante para ataques de retry).

### Execução — modo full

Análise estática do código. Para **cada** padrão em `knowledge/vulnerabilities.md`:

1. Aplique os `grep patterns` de identificação descritos lá.
2. Para cada match, classifique severidade (do catálogo) e gere finding.
3. Se houver build artifacts (`dist/`, `build/`), audite-os também para source maps e secrets em bundle.
4. Rode `npm audit --json` (ou equivalente) e incorpore.
5. Confira presença e configuração de:
   - `.gitignore` (presença das entradas obrigatórias)
   - `.env.example` (sem valores reais)
   - `.env.local` (existe localmente, mas NÃO commitado — `git ls-files` não deve retornar)
   - `scripts/security-check.sh` (presente e executável)
   - `.husky/pre-commit` (se aplicável)
6. Para cada endpoint detectado no código:
   - Confira presença de middleware `authenticate`/`authorize`.
   - Confira rate limit decoration.
   - Confira validação de input (schema).
   - Confira que a resposta passa por error handler genérico.

### Execução — modo delta

Como `full`, mas restrito aos arquivos modificados desde a base. Útil para PR review automatizado.

### Formato dos findings

Cada finding é uma seção:

```markdown
### SEC-NNN — [Título curto]

| Campo | Valor |
| --- | --- |
| **Severidade** | CRÍTICO / ALTO / MÉDIO / BAIXO / INFO |
| **CWE** | CWE-NNN |
| **OWASP** | A0X |
| **Cláusula violada** | [Artigo.Cláusula, ex.: I.1] |
| **Categoria** | [Aderência / Cobertura / Compliance / Risco / Suposição / Estática] |
| **Localização** | [arquivo:linha, ou seção do artefato de design] |
| **Modo de detecção** | [design / full / delta] |
| **Trecho** | ```código vulnerável ou citação do artefato``` |
| **Por que é problema** | [explicação clara em 2-3 linhas] |
| **PoC / Exploração** | [PoC concreto da knowledge base, contextualizado] |
| **Impacto** | [Dano potencial] |
| **Correção sugerida** | ```código corrigido ou recomendação concreta``` |
| **Teste de regressão** | [Task de teste sugerida para tasks.md] |
| **Esforço** | [XS / S / M / L — XS = 5 min, L = > 1 dia] |
| **Bloqueante?** | Sim / Não, conforme `--block-on` |
```

### Sumário executivo do relatório

Logo no topo do arquivo gerado:

```markdown
# Security Audit — [Feature Name]

**Modo:** [design|full|delta]
**Gerado em:** [ISO]
**Por:** speckit.security-audit (Clean Environment ext.)
**Threshold de bloqueio:** [critical|high|medium]

## Score

- **Findings totais:** N
- **CRÍTICOS:** N
- **ALTOS:** N
- **MÉDIOS:** N
- **BAIXOS:** N
- **INFO:** N

## Veredito

**[BLOQUEADO / APROVADO COM RESSALVAS / APROVADO]**

[Linha resumindo: "1 finding CRÍTICO impede prosseguir. Veja SEC-001."
ou "Sem findings bloqueantes. 3 ALTOS recomendados para correção antes de produção."]

## Cláusulas constitucionais com violação ativa

- I.1 (Cookie HttpOnly) — 1 violação ativa
- II.2 (Parametrização) — 1 violação
- ...

## Riscos OWASP com findings

- A01 — 2 findings
- A03 — 1 finding (CRÍTICO)
- ...

## Lista de findings

[SEC-001 a SEC-NNN, ordenados por severidade decrescente, depois por localização]

## Recomendações priorizadas

1. **Resolver IMEDIATAMENTE (CRÍTICOS):** [lista de IDs]
2. **Resolver antes de release (ALTOS):** [lista]
3. **Backlog (MÉDIOS):** [lista]
4. **Considerar (BAIXOS/INFO):** [lista]

## Pendências de Complexity Tracking

[Itens encontrados em plan.md → Complexity Tracking que ainda estão sem "Aprovado por".]

## Próximos passos

- [Se BLOQUEADO]: corrigir findings CRÍTICOS, re-rodar /speckit.security-audit.
- [Se APROVADO COM RESSALVAS]: documentar plano de remediação dos ALTOS, prosseguir.
- [Se APROVADO]: /speckit.implement pode prosseguir.
```

### Pós-execução

1. Salve em `<feature_directory>/security-audit.md` (sobrescreve a versão anterior; histórico fica no git).
2. Mostre o sumário no chat.
3. Retorne exit code:
   - `0` se APROVADO (zero findings ≥ threshold).
   - `1` se BLOQUEADO.
   - `2` se erro técnico (faltam pré-requisitos).
4. Se BLOQUEADO E sendo executado pelo hook `before_implement`, instrua claramente como pular se for emergência (`--skip-security-gate`) E que isso registra em `.specify/security-audit-trail.jsonl`.

### Princípios do auditor

- **Não invente findings.** Se um padrão da knowledge base não casa, não force.
- **Cite fonte sempre.** Cada finding linka uma cláusula da Constituição ou entrada da knowledge base.
- **Seja propositivo.** Toda crítica vem com correção concreta — não vale "use bcrypt" sem mostrar como.
- **Severidade conservadora.** Em caso de dúvida entre dois níveis, escolha o maior.
- **PII em código de exemplo.** Não copie PII real do código auditado para o relatório — sanitize.
- **Defesa em profundidade.** Mesmo se uma camada protege, anote findings em outras camadas — Constituição Cláusula V.2.
