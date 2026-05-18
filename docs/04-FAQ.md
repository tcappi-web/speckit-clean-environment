# FAQ — Spec Kit + Segurança Clean Environment

## Sobre o que é

### Por que dois pacotes (preset + extension)?

O **preset** é o piso obrigatório — substitui templates do Spec Kit para que toda spec/plan/tasks nasça com segurança. Não dá pra pular.

A **extension** adiciona comandos avançados (threat-model, audit) e hooks automáticos. Tecnicamente pode ser desligada por projeto, mas é fortemente recomendada — sem ela, perde-se a captura estruturada de contexto e a auditoria pré-implementação.

### Por que não tudo em um pacote único?

Porque presets não suportam hooks no Spec Kit 0.8.x; e separar facilita versionamento independente — mudar regras de auditoria (extension) não força recompilar templates (preset).

### Funciona com qual agente?

Testado em Claude Code (primário), Codex CLI, Cursor, Gemini CLI, GitHub Copilot. Em outros agentes suportados pelo Spec Kit deveria funcionar (templates são markdown puro), mas pode haver ajustes finos por agente.

---

## Setup

### Esqueci de instalar a extension antes da primeira feature. E agora?

Sem problema:

```bash
specify extension add clean-environment-seguranca-tools
```

A extension instala os comandos e configura os hooks. O `security-context.md` do projeto continua válido. Apenas atenção: features que você criou ANTES da extension não rodaram pelos hooks `before_plan`/`before_implement` — considere rodar `/speckit.security-audit --mode=full` retroativamente.

### Como atualizo preset/extension quando há nova versão?

```bash
specify preset update clean-environment-seguranca-core
specify extension update clean-environment-seguranca-tools
```

Como o Spec Kit preserva arquivos modificados, suas customizações (se houver) sobrevivem.

### Posso ter outro preset/extension da comunidade junto?

Pode. Spec Kit suporta stacking por prioridade. Configure:

```bash
specify preset set-priority clean-environment-seguranca-core 5   # mais alta
specify preset add outro-preset                                   # priority 10 default
```

Quando dois presets entregam o mesmo template, o de prioridade menor (5) vence.

### Funciono em Windows?

Sim. O Spec Kit gera tanto scripts `.sh` quanto `.ps1`. O `security-check.sh` da Clean Environment é `bash`, mas equivale `.ps1` está no roadmap (PR aberto em `spec-kit-private` se for prioridade do seu time). Por enquanto, use Git Bash ou WSL no Windows.

---

## Durante o fluxo

### O hook `before_plan` bloqueou meu `/speckit.plan`. Por quê?

Falta `.specify/memory/security-context.md` ou ele tem `NEEDS CLARIFICATION`. Rode `/speckit.security-context` e responda todas as perguntas.

### O hook `before_implement` encontrou CRÍTICOS. Posso pular?

Em emergência sim, com `--skip-security-gate`. Mas:

1. Toda execução com skip é registrada em `.specify/security-audit-trail.jsonl`.
2. É revisada em retrospectivas trimestrais pela Equipe de Segurança Corporativa.
3. Use apenas para hotfixes de produção genuínos. Cada skip exige justificativa textual.

Para uso normal: leia o `security-audit.md`, corrija os CRÍTICOS, re-rode a auditoria, depois prossiga.

### A spec ficou enorme com a seção Security & Privacy Impact. É normal?

Sim. Para features simples, a maioria dos itens fica desmarcada — ainda mais conciso que tentar lembrar. Para features sensíveis, ter a seção explícita é o que evita esquecimento.

### Posso pular `/speckit.threat-model` em feature pequena?

Pode, mas considere: ele leva 2 minutos e revela ameaças que não eram óbvias na spec. Em features com criticidade ALTA, ou que tocam dados sensíveis, é praticamente obrigatório (`/speckit.security-audit` em modo design vai cobrar a ausência).

### O agente quer gerar código com `dangerouslySetInnerHTML`. O que faço?

Diga "pare. dangerouslySetInnerHTML viola Cláusula II.4. Refaça com DOMPurify e justifique a necessidade." A Cláusula V.3 da Constituição manda o agente recusar — mas se ele não recusou, você reforça.

### Posso usar localStorage para algo NÃO sensível, tipo preferências?

Sim. A Cláusula I.1 restringe localStorage apenas para **tokens de sessão e dados sensíveis**. Preferências de UI (tema, idioma) são fine.

---

## Compliance

### LGPD aplica ao meu projeto?

Quase sempre, se algum usuário é brasileiro ou se a empresa processa dados de brasileiros. O `/speckit.security-context` ajuda a determinar — em dúvida, marque sim, e o gate ativa controles que não custam quase nada implementar.

### Como uso um compliance que não está nos gates do plan-template (ex.: SOX, FedRAMP)?

Adicione em `security-context.md → compliance.others`. O plan-template não tem gate específico, mas o `/speckit.security-audit` vai sinalizar que há compliance declarado sem checklist correspondente. Próximo passo: PR ao `clean-environment-seguranca-core` propondo gate específico para o novo compliance.

### Direito ao esquecimento (LGPD) na prática

Cláusula IV.4 exige que esteja implementado **antes** do release. O plan.md de qualquer feature que escreva PII deve descrever:

- Endpoint ou processo de exclusão.
- Como o backup imutável (Cláusula III.8) é tratado.
- Como o audit log é preservado (audit log é base legal específica, sobrevive à exclusão).

---

## Multi-time / governança

### Meu time quer adicionar regra própria à Constituição. Como?

Não altere `.specify/memory/constitution.md` do projeto diretamente — ele é regenerado quando o preset atualiza. Em vez disso:

1. PR no `clean-environment/spec-kit-private` propondo nova cláusula ou ajuste em uma existente.
2. Aprovação de 2 membros da Equipe de Segurança Corporativa.
3. Bump de versão do preset.
4. Times atualizam: `specify preset update clean-environment-seguranca-core`.

Para regra **local** apenas do seu projeto que não cabe na Constituição corporativa, use `.specify/templates/overrides/` (precedência mais alta que o preset).

### Como o audit trail é revisado?

A cada trimestre, a Equipe de Segurança Corporativa exporta os `.specify/security-audit-trail.jsonl` de todos os projetos ativos (via GitHub Action `ci/export-audit-trail.yml`), agrega e identifica:

- Times com mais `--skip-security-gate` (indica fricção ou conhecimento insuficiente).
- Gates mais frequentemente justificados em Complexity Tracking (indica regra que pode estar errada ou que precisa de exceção formalizada).
- Padrões de finding recorrentes (indica gap de treinamento ou ferramenta).

Métricas agregadas vão para o painel interno de Segurança (Cláusula VI.6).

### Como meu time propõe nova entrada na knowledge base?

Issue em `clean-environment/spec-kit-private` com label `kb:vulnerability`. Inclua:

- Slug
- CWE e OWASP
- Exemplo vulnerável real (sanitizado)
- PoC
- Correção testada
- Teste de regressão

PR depois. Aprovação por 2 membros da Equipe de Segurança Corporativa. Bump de versão patch da extension.

---

## Performance / desenvolvimento

### O fluxo todo está lento. Como acelero?

- Para experimentação interna sem compliance: rode `/speckit.specify` → `/speckit.plan` → `/speckit.implement` direto (pula `clarify`, `checklist`, `threat-model`). Os hooks ainda rodam, garantindo o piso.
- Para retomar features em andamento: o `.specify/feature.json` lembra qual feature está ativa; mudar de branch troca automaticamente.

### Posso desligar os hooks em dev?

```bash
specify extension config clean-environment-seguranca-tools enable_hooks=false
```

Mas: a CI da empresa (`feature-pr-check.yml`) re-liga e roda em headless no momento do PR. Se você desligou em dev, vai descobrir os findings no PR — o que é fricção pior. Recomendado deixar ligado sempre.

### O agente está muito conservador, recusando código que eu sei que é seguro

Pode acontecer. A Cláusula V.3 manda recusar e propor alternativa, mas reconhece override explícito do humano com documentação em `plan.md` + revisão por Security Champion.

Quando concordar com o agente: melhor. Quando discordar: documente em `plan.md → Complexity Tracking` e prossiga.

---

## Reportar problemas

- **Bug no preset/extension:** issue em `clean-environment/spec-kit-private`.
- **Sugestão de cláusula:** PR em `clean-environment/spec-kit-private`.
- **Vulnerabilidade descoberta em produção:** SEMPRE email para `security@cleanenvironment.com.br`, NUNCA issue pública.
- **Dúvida geral:** Slack/canal interno `#spec-kit-seguranca`.
