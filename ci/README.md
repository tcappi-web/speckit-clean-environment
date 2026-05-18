# CI workflows — Clean Environment Spec Kit

Workflows GitHub Actions que rodam no repositório privado `clean-environment/spec-kit-private` e em projetos consumidores.

## Workflows neste diretório

| Arquivo | Onde roda | O que faz |
| --- | --- | --- |
| `validate-package.yml` | `clean-environment/spec-kit-private` (push/PR para main) | Valida estrutura do preset e da extension; instala em projeto demo |
| `release.yml` | `clean-environment/spec-kit-private` (tag push) | Empacota tar.gz, calcula SHA-256, atualiza catálogo, publica release |
| `feature-pr-check.yml` | **Cada projeto consumidor** (PR para main) | Instala Spec Kit + catálogos privados; roda `/speckit.security-audit --mode=delta` em headless; posta resumo na PR; bloqueia merge em CRÍTICOS |

## Como instalar o `feature-pr-check.yml` em um projeto consumidor

```bash
# Dentro do projeto consumidor:
mkdir -p .github/workflows
curl -H "Authorization: token $GH_PAT" \
     -o .github/workflows/feature-pr-check.yml \
     "https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/ci/feature-pr-check.yml"
git add .github/workflows/feature-pr-check.yml
git commit -m "ci: Clean Environment security check"
```

E adicionar no projeto o secret `GH_TOKEN_SPECKIT_PRIVATE` (PAT com leitura do `clean-environment/spec-kit-private`):

```
Settings → Secrets and variables → Actions → New repository secret
  Name: GH_TOKEN_SPECKIT_PRIVATE
  Value: <PAT com escopo repo:read>
```

## Audit trail trimestral

Os artifacts `audit-trail-<PR-NUMBER>.jsonl` (gerados em `feature-pr-check.yml`) são exportados via job adicional `export-audit-trail.yml` (a definir, planejado para roll-out F3) que:

1. Roda no primeiro dia útil de cada trimestre.
2. Lista todos os repositórios consumidores via GitHub API.
3. Coleta artifacts de audit trail das PRs mergeadas no trimestre.
4. Agrega em um dashboard interno (Looker Studio ou equivalente).
5. Envia relatório à Equipe de Segurança Corporativa.

## Como adicionar um novo workflow

1. Adicione aqui em `ci/`.
2. Atualize esta tabela.
3. PR sob o processo de `docs/05-CONTRIBUTING.md`.
