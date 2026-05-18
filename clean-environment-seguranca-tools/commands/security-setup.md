---
description: "Instala arquivos e ferramentas de segurança no projeto: .gitignore completo, .env.example adaptado, scripts/security-check.sh, husky pre-commit, git-secrets, geração de secrets fortes via openssl."
handoffs:
  - label: "Criar Primeira Feature"
    agent: speckit.specify
    prompt: "Descreva a primeira feature do projeto."
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --paths-only
  ps: scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly
---

## User Input

```text
$ARGUMENTS
```

Argumentos opcionais:
- `--skip-husky` — não instala husky mesmo com `package.json` presente
- `--skip-git-secrets` — não configura git-secrets
- `--force` — sobrescreve arquivos existentes

## Outline

Você é a skill `speckit-security-setup` da Clean Environment. Sua responsabilidade é
**instalar** no diretório raiz do projeto todos os arquivos e ferramentas de segurança da
empresa (versões consolidadas dos documentos `01-ROTINA-SEGURANCA-CLAUDE.md` Fase 2 e
`02-KIT-INICIAL-SEGURANCA.md`).

### Pré-execução

1. Verifique que `.specify/memory/security-context.md` existe (foi rodado `/speckit.security-context`).
   - Se ausente: pare e instrua o usuário a rodar `/speckit.security-context` primeiro.
2. Leia `security-context.md` para adaptar templates à stack do projeto.
3. Detecte stack:
   - `package.json` presente → JS/TS, usa npm/yarn/pnpm. Husky aplicável.
   - `pyproject.toml`/`requirements.txt` → Python. Pre-commit Python.
   - `go.mod` → Go.
   - Misto/outro → adapta.

### Execução — em 7 etapas

#### 1. `.gitignore`

Crie ou atualize `.gitignore` na raiz do projeto com o conteúdo do template
`scripts/templates/gitignore.txt` da extension (versão completa do `02-KIT-INICIAL §1`).
**Importante:** se `.gitignore` já existe, **merge** ao invés de sobrescrever (preserve entradas customizadas do usuário, adicione as faltantes da empresa). Use `--force` para sobrescrever.

#### 2. `.env.example`

Crie `.env.example` na raiz usando o template `scripts/templates/env.example.txt`, **adaptado** à stack lida do `security-context.md`. Por exemplo:

- Se `stack.frontend` inclui Vite: adiciona seção `VITE_*`.
- Se `stack.frontend` inclui Next.js: adiciona seção `NEXT_PUBLIC_*`.
- Se `stack.database` é PostgreSQL: adiciona `DATABASE_URL=postgresql://...`.
- Se `compliance.pci_dss = true`: adiciona seção comentada para Stripe/Adyen.

Sempre inclui:
```
# JWT/Session secrets (gerar com openssl rand -hex 32)
JWT_SECRET=
REFRESH_TOKEN_SECRET=
SESSION_SECRET=
```

#### 3. `.env.local` (gerado, não commitado)

Crie `.env.local` (que está no `.gitignore`) copiando de `.env.example` e **substituindo** os campos de secret por valores gerados via:

```bash
JWT_SECRET=$(openssl rand -hex 32)
REFRESH_TOKEN_SECRET=$(openssl rand -hex 32)
SESSION_SECRET=$(openssl rand -hex 32)
ENCRYPTION_KEY=$(openssl rand -hex 32)
```

(no Windows: use `openssl` do Git Bash ou WSL; se ausente, oriente o usuário a instalar e tente `python -c 'import secrets; print(secrets.token_hex(32))'` como fallback).

Mostre **explicitamente** no output que os secrets foram gerados localmente e **NUNCA** devem ser usados em produção — produção usa secret manager separado.

#### 4. `scripts/security-check.sh`

Crie `scripts/security-check.sh` copiando de `scripts/templates/security-check.sh` (versão consolidada do `02-KIT-INICIAL §4`, com cores ANSI, 8 verificações: env files, secrets em código, console.log, dangerouslySetInnerHTML, localStorage com tokens, URLs hardcoded, SQL injection patterns, npm audit). Marque executável: `chmod +x scripts/security-check.sh`.

#### 5. Husky / pre-commit hook (se aplicável)

Se `package.json` presente e não foi passado `--skip-husky`:

```bash
npm install -D husky lint-staged
npx husky init
```

Substitua `.husky/pre-commit` pelo template `scripts/templates/husky-pre-commit.sh`:

```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"
bash scripts/security-check.sh
```

Para Python: crie `.pre-commit-config.yaml` com hook que chama `scripts/security-check.sh`.

#### 6. `git-secrets` (se disponível)

Se `git-secrets` está instalado (`command -v git-secrets`) e não foi passado `--skip-git-secrets`:

```bash
git secrets --install -f
git secrets --register-aws
git secrets --add 'sk_live_[0-9a-zA-Z]{24,}'    # Stripe
git secrets --add 'sk-ant-[0-9a-zA-Z]{40,}'     # Anthropic
git secrets --add 'sk-[A-Za-z0-9]{40,}'         # OpenAI
git secrets --add 'AIza[0-9A-Za-z\-_]{35}'      # Google
git secrets --add 'ghp_[0-9a-zA-Z]{36}'         # GitHub PAT
git secrets --add 'github_pat_[0-9a-zA-Z_]{82}' # GitHub fine-grained PAT
git secrets --add 'glpat-[0-9a-zA-Z\-_]{20}'    # GitLab
git secrets --add 'xoxb-[0-9]+-[0-9]+-[0-9a-zA-Z]{24,}'  # Slack bot
git secrets --add 'AKIA[0-9A-Z]{16}'            # AWS access key
```

Se `git-secrets` não está instalado: emita aviso amarelo e mostre comandos de instalação por OS (mac/linux/windows).

#### 7. README — seção Security

Se `README.md` existe, anexe (ou ofereça anexar) a seção de Security com o template
`scripts/templates/readme-security-section.md` (do `02-KIT-INICIAL §6`). Se não existe, crie um README mínimo.

### Pós-execução

1. Liste todos os arquivos criados/modificados.
2. Verifique se algum arquivo precisa ser commitado e ofereça:
   ```bash
   git add .gitignore .env.example scripts/security-check.sh .husky/pre-commit README.md
   git commit -m "chore(security): instalação inicial Clean Environment setup"
   ```
   **Importante:** NUNCA commite `.env.local`.

3. Mostre próximos passos:
   - `/speckit.specify <descrição da primeira feature>`
   - Para projetos legados: roda `/speckit.security-audit --mode=full` para baseline.

4. Resumo final em prosa: "Setup de segurança da Clean Environment concluído. N arquivos criados. Pre-commit hook ativo. Você pode começar `/speckit.specify`."
