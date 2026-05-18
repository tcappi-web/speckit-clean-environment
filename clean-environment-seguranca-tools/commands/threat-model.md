---
description: "Gera modelo de ameaças (STRIDE/PASTA) para a feature ativa a partir dos riscos OWASP marcados na spec. Output: specs/<feature>/threat-model.md."
handoffs:
  - label: "Continuar para Plan"
    agent: speckit.plan
    prompt: "Crie plan considerando o threat model."
  - label: "Re-rodar Auditoria"
    agent: speckit.security-audit
    prompt: "Audite spec + threat-model."
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --require-spec
  ps: scripts/powershell/check-prerequisites.ps1 -Json -RequireSpec
---

## User Input

```text
$ARGUMENTS
```

Argumentos opcionais:
- `--framework=STRIDE|PASTA` (default: lê de `.specify/extensions/clean-environment-seguranca-tools/config.yml`, fallback STRIDE)
- `--focus=<lista>` (ex.: `--focus=A01,A03` restringe a ameaças a esses riscos)

## Outline

Você é a skill `speckit-threat-model` da Clean Environment. Sua responsabilidade é **ler** a
spec.md da feature ativa, **expandir** os riscos OWASP marcados na seção *Security & Privacy
Impact* em vetores de ameaça concretos (STRIDE por default), e **gerar** o arquivo
`specs/<feature-dir>/threat-model.md` que será insumo do `/speckit.plan` e do `/speckit.security-audit`.

### Pré-execução

1. Determine a feature ativa (lê `.specify/feature.json` → `feature_directory`).
2. Lê `<feature_directory>/spec.md` — em especial a seção *Security & Privacy Impact* e *Requirements/Security Requirements*.
3. Lê `.specify/memory/security-context.md` para contexto de stack e compliance.
4. Lê `.specify/memory/constitution.md` para conhecer as cláusulas aplicáveis.
5. Lê `knowledge/vulnerabilities.md` da extension para padrões de exploração e correção.
6. Se `spec.md` tem `NEEDS CLARIFICATION` na seção Security & Privacy Impact: pare e instrua o usuário a resolver primeiro (rode `/speckit.clarify` focado em segurança).

### Execução — framework STRIDE (default)

Para **cada** risco OWASP marcado na spec, expanda em ameaças STRIDE concretas para a superfície da feature. Considere também os dados tratados e as permissões declaradas.

Estrutura de cada ameaça gerada:

```markdown
### THR-NNN — [Título curto da ameaça]

| Campo | Valor |
| --- | --- |
| **STRIDE category** | Spoofing / Tampering / Repudiation / Information Disclosure / Denial of Service / Elevation of Privilege |
| **OWASP relacionado** | A0X (lista) |
| **CWE** | CWE-NNN (se aplicável) |
| **Superfície** | [Endpoint, componente, fluxo] |
| **Ator** | [Usuário não-autenticado / Usuário autenticado mal-intencionado / Insider / Outro] |
| **Dados em risco** | [tipos de dados da spec impactados] |
| **Pré-condições** | [O que o atacante precisa para tentar] |
| **Vetor** | [Descrição em 2-3 linhas de como o ataque ocorreria] |
| **PoC** | [Snippet/cURL de exemplo, derivado de knowledge/vulnerabilities.md] |
| **Impacto** | [Severidade: CRÍTICO / ALTO / MÉDIO / BAIXO + descrição do dano] |
| **Mitigação proposta** | [1-3 controles concretos, vinculados a cláusulas da Constituição] |
| **Cláusulas constitucionais cobertas** | [ex.: II.1, II.2, I.5] |
| **Detecção** | [Como monitorar / log / alerta] |
| **Testes adversariais** | [Tasks `[SEC]` sugeridas para tasks.md] |
```

### Lista de checagens por categoria STRIDE

Considere **todas** ao analisar a feature:

#### Spoofing (Falsificação de identidade)
- Reuso de token? (rotação? expiração?)
- Falsificação de header (X-Forwarded-For, host)?
- OAuth state CSRF?
- Reuso de webhook signature?

#### Tampering (Adulteração de dados)
- Mass assignment (extra fields no POST)?
- Race condition em transações?
- Modificação de IDs em path/query (IDOR)?
- Bypass de validação client-side?

#### Repudiation (Repúdio)
- Audit log incompleto?
- Logs editáveis?
- Falta de correlation ID?

#### Information Disclosure (Vazamento)
- Stack trace em erro?
- PII em log?
- Verbose error en API?
- Timing attack revelando existência?
- Source map em produção?

#### Denial of Service (Indisponibilidade)
- Falta de rate limit?
- Falta de limite em upload?
- Queries sem paginação?
- Regex explosivo (ReDoS)?
- Zip bomb?

#### Elevation of Privilege (Escalação)
- IDOR (req.user.id ≠ resource.userId)?
- Role check faltando?
- Bypass de middleware?
- JWT confusion (alg=none)?
- SSRF para metadata cloud?

### Modo PASTA (se solicitado)

Se `--framework=PASTA`, estrutura em 7 estágios:
1. Definir objetivos (do produto + de segurança)
2. Definir escopo técnico (componentes, libs, integrações)
3. Decomposição da aplicação
4. Análise de ameaças
5. Análise de vulnerabilidades
6. Análise de ataque
7. Análise de risco e impacto

Para cada estágio, gere seção dedicada no output.

### Geração do arquivo

Escreva em `<feature_directory>/threat-model.md`:

```markdown
# Threat Model — [Feature Name]

**Feature:** [###-feature-name]
**Framework:** STRIDE (ou PASTA)
**Gerado em:** [ISO timestamp]
**Por:** speckit.threat-model (Clean Environment ext.)

## Contexto

[Resumo de 1 parágrafo da feature, dados que trata, permissões, criticidade]

## Riscos OWASP cobertos

[Lista dos riscos marcados na spec, com link para a seção correspondente]

## Ameaças identificadas

### Resumo

| ID | Categoria | OWASP | Severidade |
| --- | --- | --- | --- |
| THR-001 | Elevation of Privilege | A01 | ALTO |
| THR-002 | Injection (SQL) | A03 | CRÍTICO |
| ... | ... | ... | ... |

### Detalhamento

[Bloco de cada THR-NNN no formato acima]

## Tasks `[SEC]` sugeridas para o tasks.md

[Lista enumerada de tasks adversariais que devem ser geradas no /speckit.tasks]

## Cláusulas constitucionais cobertas

[Lista única de cláusulas únicas referenciadas pelas mitigações]

## Lacunas detectadas

[Riscos OWASP marcados na spec que NÃO geraram ameaças concretas — geralmente
porque a feature não toca essa superfície. Documentar para auditoria saber
que foram analisados e descartados, não esquecidos.]

## Próximos passos

1. Revise as ameaças e mitigações com Security Champion do time.
2. `/speckit.plan` — incorpora as mitigações no design.
3. `/speckit.tasks` — gera tasks `[SEC]` adversariais.
4. `/speckit.security-audit --mode=design` — valida antes do código.
```

### Pós-execução

1. Resumo em prosa: quantas ameaças identificadas, quantas CRÍTICAS/ALTAS, principais áreas.
2. Mostre tabela resumida de THR-001 a THR-NNN.
3. Sugira: "Revise com seu Security Champion antes de /speckit.plan."

### Comportamento defensivo

- Se um risco OWASP foi marcado na spec mas **não** se aplica à superfície real da feature (ex.: A10 SSRF mas feature não faz nenhum request HTTP de saída): registre em "Lacunas detectadas" com justificativa, **não** force ameaças artificiais.
- Se a feature tem componentes não cobertos pelos riscos marcados (ex.: feature de upload sem A04 marcado): **adicione** ameaças e sugira atualizar a spec.
