## 🔐 Security

Este projeto segue a **Constituição de Segurança da Clean Environment** instalada pelo preset `clean-environment-seguranca-core` do Spec Kit.

Antes de contribuir, leia:

- [`.specify/memory/constitution.md`](./.specify/memory/constitution.md) — 6 artigos temáticos não-negociáveis.
- [`.specify/memory/security-context.md`](./.specify/memory/security-context.md) — contexto deste projeto específico (tipo, dados, compliance, criticidade).

### Setup inicial

```bash
# 1. Clone
git clone <repo>
cd <projeto>

# 2. Instalar dependências
npm install   # ou equivalente

# 3. Copie .env.example para .env.local e preencha
cp .env.example .env.local

# 4. Rodar
npm run dev
```

### Antes de cada commit

O pre-commit hook automaticamente roda `scripts/security-check.sh`.
Para rodar manualmente:

```bash
bash scripts/security-check.sh
```

### Antes de cada PR

```bash
# Auditoria delta — apenas mudanças desta branch
# (Roda automaticamente via hook after_implement do Spec Kit)
```

### Reportar vulnerabilidades

**NUNCA** abra issue pública para vulnerabilidades.

Envie email para: `security@cleanenvironment.com.br` (substitua pelo email real)

Resposta em até 48h.

### Compliance ativo neste projeto

Veja `.specify/memory/security-context.md → compliance` para a lista efetiva.

### Variáveis de ambiente

Veja [`.env.example`](./.env.example) para a lista completa.

**NUNCA** comite `.env`, `.env.local`, ou similares — já estão em `.gitignore`.

### Auditoria

```bash
# Auditoria completa antes de release
# (ou usando o agente:)
/speckit.security-audit --mode=full
```
