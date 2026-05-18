# Primeiro projeto — passo a passo

Este documento te leva, **em detalhe**, do diretório vazio até uma feature implementada com aderência à Constituição. Use como referência ao acompanhar um novo desenvolvedor da empresa.

## Cenário de exemplo

Vamos criar **"Photo Albums"** — aplicação interna que organiza fotos em álbuns por data, com drag-and-drop. Stack: Vite + vanilla JS no frontend, SQLite local no backend. Sem login (MVP interno).

Apesar de ser MVP simples, queremos demonstrar que **todo o fluxo de segurança aplica** mesmo quando há pouco risco — porque os hábitos se formam aqui.

## Passo 1 — Criar projeto

```bash
specify init photo-albums \
    --integration claude \
    --preset clean-environment-seguranca-core
cd photo-albums
specify extension add clean-environment-seguranca-tools
```

Estrutura criada:

```
photo-albums/
├── .specify/
│   ├── templates/        # do preset
│   ├── extensions/
│   │   └── clean-environment-seguranca-tools/
│   └── extensions.yml    # registra hooks
├── .claude/skills/       # 4 comandos do preset + 4 da extension instalados
└── README.md
```

## Passo 2 — Abrir agente e capturar contexto

```bash
claude
```

```text
/speckit.security-context
```

O agente vai conduzir Q&A em 8 fases. Para Photo Albums responda:

| Pergunta | Resposta |
| --- | --- |
| Nome | photo-albums |
| Tipo | Ferramenta interna |
| Público | Internos |
| Volume | < 1.000 |
| Geografias | BR |
| Dados — PII básica | sim (nome de quem subiu, opcional) |
| Dados — sensíveis | não |
| Dados — financeiros | não |
| Dados — saúde | não |
| Dados — user-generated content | sim (fotos) |
| Compliance — LGPD | sim (atende brasileiros) |
| Compliance — GDPR/PCI/HIPAA | não |
| Stack frontend | Vite + vanilla JS |
| Stack backend | Node + Express |
| Database | SQLite |
| Cloud | on-prem |
| Auth | nenhuma (MVP interno) |
| Criticidade | BAIXO |
| OWASP — A04, A05, A09 prováveis | confirmar |

Resultado: `.specify/memory/security-context.md` gerado.

## Passo 3 — Gerar Constitution

```text
/speckit.constitution
```

O comando lê o security-context e gera `.specify/memory/constitution.md` instanciado com:
- Compliance LGPD ativo no Artigo IV.
- Compliance GDPR/PCI/HIPAA inativos (gates dormentes nos templates).
- Criticidade BAIXO → 2FA não-obrigatório (Cláusula I.8 N/A).

## Passo 4 — Setup de ambiente

```text
/speckit.security-setup
```

O comando:
1. Cria `.gitignore` completo
2. Cria `.env.example` (adaptado: tem `VITE_API_URL`, omite `STRIPE_*`)
3. Cria `.env.local` com `JWT_SECRET`, `SESSION_SECRET` gerados por `openssl rand -hex 32` (avisa que são para dev, produção usa secret manager)
4. Cria `scripts/security-check.sh` executável
5. Como `package.json` existe (criamos no init): instala husky + lint-staged + `.husky/pre-commit`
6. Detecta `git-secrets` no PATH; se presente, configura padrões
7. Anexa seção Security ao README.md

Commit inicial:

```bash
git add .gitignore .env.example scripts/.husky/pre-commit README.md
git commit -m "chore(security): Clean Environment setup inicial"
```

## Passo 5 — Primeira feature

```text
/speckit.specify Organize fotos em álbuns. Cada álbum tem nome e data. Fotos
são previewadas em tiles. Drag-and-drop reordena álbuns na home. Álbuns não
têm aninhamento.
```

Branch `001-photo-albums-home` é criada. `specs/001-photo-albums-home/spec.md` aparece. Abra e preencha a seção **Security & Privacy Impact**:

- Dados tratados: ☑ Conteúdo gerado por usuário (fotos); ☐ resto.
- Operações: ☑ Leitura, ☑ Criação, ☑ Atualização (reordenar), ☑ Exclusão.
- Permissões: ☑ Público (sem auth — MVP interno).
- OWASP aplicáveis: ☑ A03 (injection no nome do álbum), ☑ A04 (insecure design — sem auth pode ser intencional ou falha?), ☑ A05 (config), ☑ A09 (logs sem PII por consequência).
- Compliance LGPD herdado: sim. Esta feature trata "fotos" como dado pessoal → política de privacidade aplicável.

Se você marcou `[NEEDS CLARIFICATION]` em algum item, próximo passo:

```text
/speckit.clarify
```

## Passo 6 — Validar requisitos

```text
/speckit.checklist
```

Roda os 12 grupos do checklist. Em MVP interno, vários itens são N/A — o checklist exige que cada N/A tenha justificativa.

## Passo 7 — Threat model

```text
/speckit.threat-model
```

Gera `specs/001-photo-albums-home/threat-model.md`. Por exemplo:

- **THR-001 (A03, Tampering):** SQL injection no nome do álbum se backend concatenar.
- **THR-002 (A05, Information Disclosure):** Diretório de upload acessível publicamente.
- **THR-003 (A03/Tampering):** XSS armazenado no nome do álbum quando renderizado na home.
- **THR-004 (A09, Repudiation):** Falta de audit log de exclusão de álbum.

Cada ameaça vem com mitigação concreta vinculada às Cláusulas II.1, II.2, II.4, IV.8.

## Passo 8 — Plan

```text
/speckit.plan Vite + vanilla JS + Express + SQLite. Imagens em diretório
local com nome UUID. Metadata em SQLite via better-sqlite3 com prepared
statements.
```

Plan gerado tem **Security Gate** + **Compliance Gate LGPD** preenchidos. Endereça as THRs do threat-model:

- Cláusula II.2 ✓ (better-sqlite3 com bind).
- Cláusula II.6 ✓ (UUID + magic bytes para upload).
- Cláusula II.4 ✓ (vanilla JS sem dangerouslySetInnerHTML; valor escapado).
- Cláusula IV.8 ✓ (audit log de exclusões em SQLite).

## Passo 9 — Tasks

```text
/speckit.tasks
```

Gera `tasks.md` com:
- Tasks funcionais (T001–T015)
- Bloco "Segurança (transversal)" com T001-SEC1 (security-setup), T010-SEC1 (validação nome do álbum), T012-SEC1 (UUID upload), T012-SEC2 (magic bytes), T013-SEC1 (audit log exclusão), etc.
- Testes adversariais (T015-SEC1: XSS no nome, T015-SEC2: SQLi no nome, T015-SEC3: upload de arquivo não-imagem, T015-SEC4: path traversal no GET de foto).

## Passo 10 — Análise + Auditoria

```text
/speckit.analyze
```

Verifica consistência spec/plan/tasks. Sem inconsistências, próximo passo.

```text
/speckit.security-audit --mode=design
```

(Roda automaticamente pelo hook `before_implement` antes de `/speckit.implement` — mas você pode rodar manualmente também.)

Relatório `specs/001-photo-albums-home/security-audit.md` é gerado. Para Photo Albums espera-se zero findings críticos.

## Passo 11 — Implementar

```text
/speckit.implement
```

Spec Kit executa cada task na ordem. Ao final, o hook `after_implement` roda `bash scripts/security-check.sh --post-implement` automaticamente. Saída esperada:

```
✅ Todos os checks passaram
```

Se algo falhar (ex.: o agente esqueceu de parametrizar uma query), o hook bloqueia e sugere:

```text
/speckit.security-audit --mode=delta --target=specs/001-photo-albums-home
```

## Passo 12 — PR

```bash
git push origin 001-photo-albums-home
gh pr create --title "feat: photo albums home" --body "$(cat specs/001-photo-albums-home/spec.md | head -80)"
```

GitHub Action `feature-pr-check.yml` roda automaticamente: instala Spec Kit, valida que os artefatos existem, roda `/speckit.security-audit --mode=delta` em headless, anexa o relatório como comentário do PR.

Aprovação humana + revisão de Security Champion (Cláusula V.4) → merge.

## Resumindo

Em ~1h, Photo Albums foi modelada com segurança rastreável, sem nada artesanal. **Os mesmos princípios escalam** para um e-commerce com PCI-DSS ou um sistema clínico com HIPAA — muda só o conjunto de gates ativos no plan-template.
