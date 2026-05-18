# Treinamento de 1 hora — Spec Kit + Segurança Clean Environment

Roteiro para conduzir treinamento presencial ou remoto de **60 minutos** para um time que vai começar a usar o pacote da Clean Environment.

## Pré-requisitos do treinamento

- Cada participante com Spec Kit instalado e PAT GitHub configurado (idealmente fazer setup-único previamente).
- Projetor / share de tela do instrutor.
- Repositório de demonstração `clean-environment/spec-kit-demo` (greenfield, vazio).
- Material impresso: `CHECKLIST-RAPIDO.md` da pasta original.

## Agenda

| Tempo | Bloco | Atividade |
| --- | --- | --- |
| 0:00–0:05 | Abertura | Por que existe este pacote, o que muda na rotina |
| 0:05–0:20 | Conceitos | Spec-Driven Development, Constitution, 6 artigos, gates condicionais |
| 0:20–0:35 | Demo ao vivo | Setup zero → spec → plan → tasks (sem implement) |
| 0:35–0:45 | Mão-na-massa | Time roda o mesmo fluxo no laptop de cada um |
| 0:45–0:55 | Troubleshooting | Erros comuns, como reagir aos hooks, audit trail |
| 0:55–1:00 | Próximos passos | Onde achar docs, como pedir ajuda, próxima sessão |

## Bloco 1 — Abertura (5 min)

**Mensagem-chave:** Não é "mais um processo". É a **única** forma de garantir que segurança não vire dívida técnica. Com Spec Kit + os 6 artigos, segurança é **dimensão de toda decisão**.

**Mostre:** uma vulnerabilidade real recente (sanitizada) que **teria sido capturada** pelo fluxo — gate constitucional, threat-model ou security-audit. Se não tiver caso real, use os exemplos de `knowledge/vulnerabilities.md`.

## Bloco 2 — Conceitos (15 min)

Apresentação em 5 slides:

### Slide 1 — Spec-Driven Development
- A spec é fonte de verdade, código é expressão.
- Por que LLMs precisam de templates rígidos (constranger é libertador).
- Comparação: 12h de doc tradicional vs 15 min com Spec Kit.

### Slide 2 — Por que adicionamos segurança
- Os 5 documentos originais (mostre capa de cada) — sem disciplina, esses ficam na gaveta.
- O preset força os princípios a aparecerem em cada artefato.
- A extension adiciona ferramentas que automatizam o "lembrar".

### Slide 3 — Constituição em 6 artigos
- I — Identidade e Acesso
- II — Integridade dos Dados
- III — Resiliência e Operação
- IV — Privacidade e Compliance (condicional)
- V — Cultura e Processo
- VI — Governança e Evolução

Cada artigo tem cláusulas concretas. Cada cláusula vira gate.

### Slide 4 — Fluxo de uma feature
Diagrama: specify → clarify → checklist → threat-model → plan → tasks → analyze → security-audit → implement.

Destaque os 3 hooks automáticos (before_plan, before_implement, after_implement).

### Slide 5 — O que NÃO muda
- Você continua escrevendo código.
- O agente continua sendo seu copiloto.
- Apenas: a estrutura ao redor força perguntas certas no momento certo.

## Bloco 3 — Demo ao vivo (15 min)

Faça **literalmente** o passo-a-passo do `docs/02-PRIMEIRO-PROJETO.md` em modo demo. Marque o tempo:

- Setup do projeto: 30s
- `/speckit.security-context`: 4 min (mostre Q&A)
- `/speckit.constitution`: 30s
- `/speckit.security-setup`: 1 min
- `/speckit.specify` de feature pequena: 2 min
- `/speckit.threat-model`: 2 min (mostre o relatório gerado)
- `/speckit.plan`: 2 min (mostre os gates preenchidos)
- `/speckit.tasks`: 2 min (mostre tasks [SEC])
- Pause antes do `/speckit.implement`.

Total: 15 min com sobra para perguntas.

## Bloco 4 — Mão-na-massa (10 min)

Cada participante:

```bash
specify init meu-treino --integration claude --preset clean-environment-seguranca-core
cd meu-treino
specify extension add clean-environment-seguranca-tools
claude
```

```text
/speckit.security-context
```

Use cenário simplificado fornecido em handout: "ferramenta interna para times tirarem dúvidas técnicas usando IA, sem PII, criticidade BAIXA".

Resultado esperado: arquivo `security-context.md` gerado em ~3 min. Quem terminar antes faz `/speckit.constitution`.

## Bloco 5 — Troubleshooting (10 min)

Discussão dirigida com os 5 erros mais comuns:

1. **"O hook before_plan bloqueou meu /speckit.plan"** → rode `/speckit.security-context` primeiro. Sempre.
2. **"O hook before_implement encontrou CRÍTICOS"** → leia `security-audit.md`, corrija, re-rode auditoria. NÃO use `--skip-security-gate` exceto em hotfix.
3. **"O after_implement falhou em meu console.log"** → console.log é warning, não erro; o que falhou foi outra coisa. Releia o output.
4. **"Como atualizo o preset/extension"** → `specify preset update clean-environment-seguranca-core` ou `specify extension update clean-environment-seguranca-tools`.
5. **"Posso usar Cursor em vez de Claude Code?"** → sim, `--integration cursor-agent`. Os comandos funcionam idênticos.

Mostre **onde** está o audit trail (`.specify/security-audit-trail.jsonl`) e que ele é revisado em retros trimestrais — não para punir, para aprender.

## Bloco 6 — Próximos passos (5 min)

- **Hoje:** completar a feature de treino até `/speckit.implement` em casa.
- **Esta semana:** Security Champion do time aplica o preset/extension no próximo projeto real.
- **Próxima retrospectiva:** trazer 1 dúvida + 1 sugestão de melhoria para o catálogo.
- **Canal:** `#spec-kit-seguranca` no Slack/Discord/equivalente.
- **Documentação:** `clean-environment/spec-kit-private/docs/`.

## Material complementar

Distribua impresso ou compartilhe links:
- `CHECKLIST-RAPIDO.md` (impresso para colar na parede)
- `docs/04-FAQ.md`
- `docs/02-PRIMEIRO-PROJETO.md`

## Métricas de sucesso do treinamento

Para validar que a sessão funcionou:

- [ ] 100% dos participantes conseguem rodar `/speckit.security-context` ao final.
- [ ] Pelo menos 80% conseguem chegar até `/speckit.tasks`.
- [ ] 100% sabem onde procurar quando um hook bloquear.
- [ ] Pelo menos 50% propõem uma melhoria nos templates dentro de 30 dias (sinal de engajamento real).

Coleta-se via formulário curto pós-treino + observação na primeira sprint do time.
