# Clean Environment — Segurança (Extension Tools)

Extension oficial da **Clean Environment** que complementa o preset `clean-environment-seguranca-core` com:

- **4 comandos novos** (`/speckit.security-context`, `/speckit.security-setup`, `/speckit.threat-model`, `/speckit.security-audit`)
- **3 hooks automáticos** (`before_plan`, `before_implement`, `after_implement`)
- **1 knowledge base** (`knowledge/vulnerabilities.md`) com 15+ padrões catalogados
- **Scripts auxiliares** (`.gitignore`, `.env.example`, `security-check.sh`, husky pre-commit)

## Instalação

```bash
# Pré-requisito: ter o preset instalado
specify init meu-projeto --integration claude --preset clean-environment-seguranca-core
cd meu-projeto

# Instalar a extension
specify extension add clean-environment-seguranca-tools
```

## Instalação a partir do GitHub privado da empresa

```bash
# Via catálogo privado:
export SPECKIT_CATALOG_URL="https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/catalogs/extension-catalog.json"
specify extension add clean-environment-seguranca-tools

# Via URL direta:
specify extension add clean-environment-seguranca-tools \
    --from "https://github.com/clean-environment/spec-kit-private/raw/main/clean-environment-seguranca-tools.tar.gz"

# Desenvolvimento local:
specify extension add --dev /caminho/local/clean-environment-seguranca-tools
```

## Os 4 comandos

| Comando | O que faz | Quando usar |
| --- | --- | --- |
| `/speckit.security-context` | Q&A interativa que captura `.specify/memory/security-context.md` (tipo de projeto, dados tratados, compliance aplicável, stack, criticidade, estratégia de autenticação) | **Uma vez no início do projeto**, antes de `/speckit.constitution`. Re-executar quando o contexto mudar (ex.: nova feature traz dados de cartão e ativa PCI-DSS). |
| `/speckit.security-setup` | Instala `.gitignore` completo, `.env.example` adaptado à stack, `scripts/security-check.sh`, configura husky pre-commit, executa `git-secrets --install`, gera secrets fortes em `.env.local` via `openssl rand -hex 32` | **Logo após `/speckit.constitution`**, antes da primeira feature. |
| `/speckit.threat-model` | Lê `spec.md` da feature ativa, expande riscos OWASP marcados em vetores STRIDE concretos, sugere mitigações; gera `specs/<feature>/threat-model.md` | **Após `/speckit.specify` (e idealmente após `/speckit.clarify`)**, antes de `/speckit.plan`. Especialmente útil para features com criticidade ALTA ou que tocam dados sensíveis. |
| `/speckit.security-audit` | Auditoria OWASP+Constitution. Modo `design` (analisa spec/plan/tasks sem código); modo `full` (varre código atual); modo `delta` (apenas mudanças desde último commit). Consulta `knowledge/vulnerabilities.md` para PoCs e correções. Produz `specs/<feature>/security-audit.md` com severidade, CWE, exploração, correção, teste de regressão | **Pré-implement** (modo design, automático via hook), **pré-deploy** (modo full), **pós-mudanças críticas** (modo delta). |

## Os 3 hooks

| Hook | Disparo | Bloqueia? | Override |
| --- | --- | --- | --- |
| `before_plan` | Antes de `/speckit.plan` | Sim, se `security-context.md` ausente ou tem `NEEDS CLARIFICATION` | Não há override — você precisa rodar `/speckit.security-context` |
| `before_implement` | Antes de `/speckit.implement` | Sim, se auditoria em modo design reporta achado CRÍTICO | `/speckit.implement --skip-security-gate` registra em `.specify/security-audit-trail.jsonl` (exige justificativa) |
| `after_implement` | Após `/speckit.implement` | Sim, se `security-check.sh` falha | Não há override — corrigir e re-rodar |

Hooks são declarados em `.specify/extensions.yml` no projeto (formato suportado por Spec Kit 0.8.11+, ver `templates/commands/plan.md` linhas 26–56 do core).

## Configuração

A extension expõe configuração por projeto em `.specify/extensions/clean-environment-seguranca-tools/config.yml`:

```yaml
enable_hooks: true                  # liga/desliga hooks (não recomendado desligar)
audit_default_mode: "design"        # design | full | delta
threat_model_framework: "STRIDE"    # STRIDE | PASTA
vulnerability_kb_path: "knowledge/vulnerabilities.md"
block_on_critical: true             # bloqueia em achados CRÍTICOS
block_on_high: false                # bloqueia em achados ALTOS — recomendado true para criticidade ≥ ALTA
```

## Knowledge base

`knowledge/vulnerabilities.md` cataloga 15+ padrões: XSS (refletido, armazenado, DOM), SQLi/NoSQLi, IDOR, CSRF, hardcoded secrets, open redirect, path traversal, SSRF, deserialização insegura, CORS misconfiguration, falta de rate limit, hash fraco, PII em logs, mass assignment, command injection.

Cada entrada tem:
- Severidade e CWE
- Identificação (grep patterns)
- Exemplo vulnerável
- PoC de exploração
- Código corrigido
- Teste de regressão

A knowledge base é versionada com a extension. Atualizações por PR no repositório `spec-kit-private`. Times podem propor novas entradas via issue + PR.

## Audit trail

Qualquer uso de `--skip-security-gate` é registrado em `.specify/security-audit-trail.jsonl` (uma linha JSON por evento) com:

```json
{
  "timestamp": "2026-05-17T22:30:00Z",
  "actor": "queenbee.hivemind@gmail.com",
  "command": "speckit.implement",
  "skipped_gate": "before_implement",
  "justification": "Hotfix de produção — bug crítico em /api/billing; auditoria full agendada para próxima sprint",
  "severity_of_findings_skipped": "1 CRÍTICO, 2 ALTOS"
}
```

Retenção: 2 anos. Arquivo deve ser commitado e revisado em retrospectivas trimestrais.

## Multi-agente

Testado em:

| Agente | Status | Localização dos comandos |
| --- | --- | --- |
| Claude Code | ✅ Primário | `.claude/skills/speckit-*/SKILL.md` |
| Codex CLI | ✅ Suportado | `.agents/skills/speckit-*/SKILL.md` (invocação: `$speckit-security-audit`) |
| Cursor | ✅ Suportado | `.cursor/skills/` |
| Gemini CLI | ✅ Suportado | `.gemini/commands/*.toml` |
| Copilot | ✅ Suportado | `.github/skills/` ou `.github/prompts/` |
| Outros | ⚠️ Genérico | Conforme Spec Kit registry |

## Como contribuir

PRs no repositório `spec-kit-private` da Clean Environment. Mesmos requisitos do preset:

1. Aprovação de Security Champion do time autor.
2. Aprovação de pelo menos 1 membro da Equipe de Segurança Corporativa.
3. CI: instalação automática em projeto piloto + execução do fluxo completo + diff dos artefatos.
