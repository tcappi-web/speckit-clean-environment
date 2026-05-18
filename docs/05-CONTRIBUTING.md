# Contribuindo com o pacote Clean Environment

Este documento define **como** propor mudanças no preset, na extension, na knowledge base e nos templates.

## Princípios

1. **Constituição é viva, mas auditada.** Cláusulas mudam, mas sob processo (Artigo VI da Constituição).
2. **Toda mudança rastreável.** PR → revisão → CI verde → release tagueado.
3. **Backward compatibility por default.** Mudanças que quebram specs/plans existentes exigem semver major + plano de migração para times afetados.

## O que pode ser proposto

| Tipo | Pacote afetado | Quem aprova | Severidade semver |
| --- | --- | --- | --- |
| Nova entrada na knowledge base | extension | 2× Segurança Corporativa | patch |
| Refinamento de gate existente | preset (plan-template) | 2× Segurança Corporativa | minor |
| Novo compliance gate (ex.: SOX, FedRAMP) | preset | 2× Segurança Corporativa + Diretoria | minor |
| Nova cláusula constitucional | preset (constitution-template) | 2× Segurança Corporativa + Conselho de Segurança | major |
| Novo comando da extension | extension | 2× Segurança Corporativa + 1 Tech Lead consumidor | minor |
| Novo hook | extension | 2× Segurança Corporativa + 1 Tech Lead consumidor | minor |
| Correção de bug em script | extension (scripts) | 1× Segurança Corporativa | patch |
| Atualização de prompt em SKILL.md | extension (commands) | 1× Segurança Corporativa | patch |
| Atualização de docs/ | qualquer | 1× Segurança Corporativa | (sem bump) |

## Fluxo

```
1. Issue no clean-environment/spec-kit-private (template apropriado)
2. Branch a partir de main: feature/<descrição-curta>
3. PR aberta — preencher template de PR
4. CI roda automaticamente:
   - validate-preset.yml (estrutura do preset)
   - validate-extension.yml (estrutura da extension)
   - integration-test.yml (instala em projeto demo e roda fluxo sintético)
5. Revisão por reviewers obrigatórios (ver tabela acima)
6. Após aprovação + CI verde: merge para main
7. Release tag: git tag clean-environment-seguranca-<core|tools>-vX.Y.Z
8. Action release.yml empacota, calcula checksum, atualiza catalogs/*.json, publica release
9. Comunicação no canal #spec-kit-seguranca
```

## Templates de issue

### Issue: Nova entrada na knowledge base

```markdown
**Slug proposto:** [ex.: prototype-pollution]
**CWE:** CWE-NNN
**OWASP:** A0X
**Severidade default:** CRÍTICO / ALTO / MÉDIO

### Descrição
[O que é a vulnerabilidade]

### Identificação
[Padrões grep]

### Exemplo vulnerável (sanitizado)
[Código]

### PoC
[Como explorar]

### Correção
[Código corrigido]

### Teste de regressão
[Snippet de teste]
```

### Issue: Refinamento de gate

```markdown
**Gate atual:** [Citação literal do plan-template]
**Problema:** [Por que precisa mudar]
**Proposta:** [Novo gate]
**Impacto em projetos existentes:** [análise]
**Plano de migração (se quebra):** [passos]
```

### Issue: Nova cláusula constitucional

```markdown
**Artigo proposto:** [I / II / III / IV / V / VI]
**Cláusula proposta (texto literal):** [...]
**Justificativa:**
  - Incidente recente: [...]
  - Novo padrão da indústria: [...]
  - Nova regulação: [...]
  - Retrospectiva: [...]
**Cláusulas relacionadas:** [...]
**Como vai ser verificada (gate / hook / audit):** [...]
**Aprovação requerida do Conselho de Segurança:** sim/não
```

## Template de PR

```markdown
## Tipo
- [ ] patch (bugfix, doc, novo item de kb)
- [ ] minor (nova feature retrocompatível)
- [ ] major (breaking change)

## Descrição
[O que muda, por quê]

## Issue relacionada
Closes #NNN

## Checklist
- [ ] CI verde
- [ ] Documentação atualizada (`docs/`)
- [ ] CHANGELOG.md atualizado
- [ ] Versão bumpada em preset.yml / extension.yml
- [ ] Catálogo (`catalogs/*.json`) atualizado com nova versão
- [ ] Para breaking change: plano de migração em `docs/migrations/`
- [ ] Para nova cláusula: revisão e aprovação do Conselho de Segurança anexada

## Testado em
- [ ] Claude Code
- [ ] Codex CLI
- [ ] Cursor
- [ ] Gemini CLI
- [ ] GitHub Copilot
```

## Como rodar o CI localmente

```bash
# Validar preset
bash ci/scripts/validate-preset.sh clean-environment-seguranca-core/

# Validar extension
bash ci/scripts/validate-extension.sh clean-environment-seguranca-tools/

# Teste de integração — cria projeto demo e roda fluxo sintético
bash ci/scripts/integration-test.sh
```

## Code of Conduct interno

Discussões sobre cláusulas têm peso de **decisão de governança**. Respeito mútuo é regra. Discordância técnica é bem-vinda — discordância sobre incidentes reais ou questões legais exige cuidado redobrado e geralmente envolve áreas além de Engenharia.

## Reconhecimento de contribuição

- Toda PR mergeada → linha em `CHANGELOG.md` com autor.
- Toda entrada de knowledge base → autor citado.
- Contribuições significativas (nova cláusula, novo comando) → reconhecimento público no canal de Segurança da empresa.
