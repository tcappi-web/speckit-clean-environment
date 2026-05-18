# Guia de Rollout — Clean Environment Spec Kit Security Pack

**Para:** Tiago  
**Versão do pacote:** 1.0.0  
**Data:** 2026-05-18

Este guia é dividido em três blocos:

1. **O que você faz ANTES** (ações manuais no GitHub e no seu computador)
2. **O que está pronto** (o que foi preparado e não exige ação sua)
3. **O que você faz DEPOIS** (publicar a primeira release e distribuir para os times)

---

## BLOCO 1 — O que você faz ANTES de qualquer push

### Passo 1 — Criar a organização (se ainda não existir)

O repositório privado precisa viver em `github.com/clean-environment`. Se a organização GitHub `clean-environment` ainda não existe:

1. Acesse github.com → clique na foto de perfil → **Your organizations** → **New organization**
2. Escolha o plano (Team ou Enterprise para repositórios privados)
3. Nome: `clean-environment`

Se a organização já existe, pule para o Passo 2.

---

### Passo 2 — Criar o repositório privado

No GitHub, dentro da organização `clean-environment`:

1. Clique em **New repository**
2. Preencha:
   - **Repository name:** `spec-kit-private`
   - **Visibility:** `Private`
   - **Não marque** "Add a README file" (o README já vem do push)
3. Clique em **Create repository**

O repositório ficará em: `https://github.com/clean-environment/spec-kit-private`

---

### Passo 3 — Criar um Personal Access Token (PAT) para o CI

O workflow `release.yml` faz commit automático no branch `main` para atualizar os catálogos. Para isso, ele precisa de um PAT com permissão de escrita.

1. Acesse: **github.com → Settings → Developer settings → Personal access tokens → Fine-grained tokens → Generate new token**
2. Preencha:
   - **Token name:** `ce-speckit-release-bot`
   - **Expiration:** 1 year (ou conforme política interna)
   - **Resource owner:** `clean-environment`
   - **Repository access:** Only selected → `spec-kit-private`
   - **Permissions:**
     - `Contents`: **Read and write**
     - `Metadata`: **Read-only** (obrigatório automaticamente)
3. Clique em **Generate token** e **copie o valor** — você não verá novamente.

---

### Passo 4 — Adicionar o PAT como secret do repositório

No repositório `clean-environment/spec-kit-private`:

1. Vá em **Settings → Secrets and variables → Actions → New repository secret**
2. Crie o secret:
   - **Name:** `CE_RELEASE_BOT_TOKEN`
   - **Value:** o token gerado no Passo 3

> **Por que não usar o `GITHUB_TOKEN` padrão?** O workflow de release faz `git push origin HEAD:main` diretamente. O `GITHUB_TOKEN` padrão não pode fazer push quando a branch `main` tem proteções ativas. O PAT dedicado contorna isso.

---

### Passo 5 — Configurar proteção do branch `main` (recomendado)

Para que ninguém faça push acidental direto na `main`:

1. Vá em **Settings → Branches → Add branch protection rule**
2. **Branch name pattern:** `main`
3. Marque:
   - **Require a pull request before merging**
   - **Require status checks to pass before merging** → adicione `Validate preset structure and templates` e `Validate extension structure and commands`
4. Em **Allow specific actors to bypass required pull requests**, adicione o usuário/bot associado ao PAT criado no Passo 3 (ou deixe vazio para começar — o CI já tem permissão via PAT)
5. Clique em **Create**

---

### Passo 6 — Atualizar o arquivo `release.yml` com o nome do secret

O workflow de release atualmente usa `GITHUB_TOKEN` para fazer push. Precisa ser atualizado para usar o PAT que você acabou de criar.

Abra o arquivo `.github/workflows/release.yml` na sua pasta de trabalho e localize o step "Commit catalog update". Ele faz `git push origin HEAD:main` mas não especifica token explicitamente — o que pode falhar com proteção de branch ativa.

Adicione a linha abaixo no step "Checkout" do `release.yml`:

```yaml
      - name: Checkout
        uses: actions/checkout@v4
        with:
          token: ${{ secrets.CE_RELEASE_BOT_TOKEN }}
```

Isso garante que o checkout já configura o remote com o PAT correto para o push subsequente.

---

### Passo 7 — Criar um PAT de leitura para os times (consumidores)

Os projetos dos times precisam de um token com acesso de **leitura** ao `spec-kit-private` para buscar os catálogos e para o workflow `feature-pr-check.yml`.

1. Acesse: **github.com → Settings → Developer settings → Personal access tokens → Fine-grained tokens → Generate new token**
2. Preencha:
   - **Token name:** `ce-speckit-read`
   - **Expiration:** 1 year
   - **Repository access:** `spec-kit-private`
   - **Permissions:** `Contents: Read-only`, `Metadata: Read-only`
3. Copie o token — você distribuirá ele para os times (ou usará o GitHub Secrets do repositório consumidor).

---

## BLOCO 2 — O que está pronto (sem ação necessária sua)

Os arquivos abaixo foram criados ou estão prontos na sua pasta de trabalho:

| Arquivo | Status | O que faz |
|---|---|---|
| `.github/workflows/validate-package.yml` | ✅ Criado | Valida estrutura e instala em projeto demo a cada push/PR na `main` |
| `.github/workflows/release.yml` | ✅ Criado | Empacota, calcula SHA-256, atualiza catálogo, publica release ao criar uma tag |
| `.markdownlint-cli2.jsonc` | ✅ Criado | Config de linting markdown usada pelo CI |
| `catalogs/preset-catalog.json` | ✅ Pronto | Catálogo privado do preset — checksums serão preenchidos pela CI no primeiro release |
| `catalogs/extension-catalog.json` | ✅ Pronto | Catálogo privado da extension — idem |
| `clean-environment-seguranca-core/` | ✅ Pronto | Preset com 5 templates, preset.yml, README |
| `clean-environment-seguranca-tools/` | ✅ Pronto | Extension com 4 comandos, 3 hooks, knowledge base, scripts |
| `docs/` | ✅ Pronto | 5 documentos de documentação interna |
| `ci/` | ✅ Pronto | Cópias de referência dos workflows (os ativos são os de `.github/workflows/`) |
| `README.md` | ✅ Pronto | Entrypoint do repositório privado |

**Atenção:** Após fazer o Passo 6 do Bloco 1, o arquivo `.github/workflows/release.yml` na sua pasta estará correto. Não é preciso editar mais nada.

---

## BLOCO 3 — O que você faz DEPOIS do push

### Passo A — Fazer o push inicial

Na sua máquina, dentro da pasta `clean-environment-seguranca/`:

```bash
cd caminho/para/clean-environment-seguranca

git init -b main
git add .
git commit -m "feat: Clean Environment Spec Kit security pack v1.0.0"
git remote add origin https://github.com/clean-environment/spec-kit-private.git
git push -u origin main
```

Após o push, o CI de `validate-package.yml` vai rodar automaticamente. Aguarde ele passar (verde) antes de continuar.

---

### Passo B — Publicar a primeira release (preset)

Com o CI passando, crie a tag do preset:

```bash
git tag clean-environment-seguranca-core-v1.0.0
git push origin clean-environment-seguranca-core-v1.0.0
```

O workflow `release.yml` vai disparar automaticamente e:
1. Validar que a tag bate com a versão em `preset.yml`
2. Criar o tarball `clean-environment-seguranca-core.tar.gz`
3. Calcular o SHA-256
4. Atualizar `catalogs/preset-catalog.json` com checksum e URL reais
5. Fazer commit e push do catálogo atualizado na `main`
6. Publicar a release em `github.com/clean-environment/spec-kit-private/releases`

---

### Passo C — Publicar a primeira release (extension)

Após o preset ser publicado com sucesso:

```bash
git tag clean-environment-seguranca-tools-v1.0.0
git push origin clean-environment-seguranca-tools-v1.0.0
```

Mesmo fluxo da etapa anterior, agora para a extension.

---

### Passo D — Verificar os catálogos publicados

Confirme que os catálogos foram atualizados com checksums reais:

```
https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/catalogs/preset-catalog.json
https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/catalogs/extension-catalog.json
```

Os campos `checksum_sha256` não devem mais conter `[CHECKSUM_GERADO_NO_BUILD]`.

---

### Passo E — Testar localmente (projeto piloto)

Em uma máquina de desenvolvimento (pode ser a sua), faça o setup de desenvolvedor e teste o projeto piloto:

```bash
# 1. Instalar Spec Kit CLI
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v0.8.11

# 2. Autenticar com o token de leitura criado no Passo 7
gh auth login --scopes repo
# (use o token ce-speckit-read quando solicitado)

# 3. Configurar as variáveis de ambiente (adicione ao ~/.bashrc ou ~/.zshrc)
export SPECKIT_PRESET_CATALOG_URL="https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/catalogs/preset-catalog.json"
export SPECKIT_CATALOG_URL="https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/catalogs/extension-catalog.json"

# 4. Verificar que o catálogo privado aparece
specify preset search clean-environment
# Esperado: "clean-environment-seguranca-core" listado

# 5. Criar projeto piloto
specify init projeto-piloto --integration claude --preset clean-environment-seguranca-core
cd projeto-piloto
specify extension add clean-environment-seguranca-tools

# 6. Abrir o agente e testar o fluxo completo (ver docs/02-PRIMEIRO-PROJETO.md)
claude
```

---

### Passo F — Instalar o CI de segurança nos projetos dos times

Para cada projeto existente (ou novo) que vai adotar o pacote, o time precisa:

1. Copiar o arquivo `ci/feature-pr-check.yml` para `.github/workflows/` do projeto:

```bash
# Dentro do repositório do projeto consumidor:
mkdir -p .github/workflows
curl -H "Authorization: token SEU_TOKEN_DE_LEITURA" \
     -o .github/workflows/feature-pr-check.yml \
     "https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/ci/feature-pr-check.yml"
git add .github/workflows/feature-pr-check.yml
git commit -m "ci: Add Clean Environment security check"
git push
```

2. Adicionar o secret `GH_TOKEN_SPECKIT_PRIVATE` no repositório do projeto (o token de leitura do Passo 7):

```
Settings → Secrets and variables → Actions → New repository secret
  Name:  GH_TOKEN_SPECKIT_PRIVATE
  Value: <token ce-speckit-read>
```

---

### Passo G — Distribuir para os times

Com o projeto piloto validado:

1. **Configure as variáveis de ambiente** em todas as máquinas dos devs (ou via `.envrc` com `direnv`):

```bash
# Adicionar ao onboarding padrão da empresa:
export SPECKIT_PRESET_CATALOG_URL="https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/catalogs/preset-catalog.json"
export SPECKIT_CATALOG_URL="https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/catalogs/extension-catalog.json"
```

2. **Agende o treinamento de 1h** conforme `docs/03-TREINAMENTO-1H.md`.

3. **Compartilhe o token de leitura** `ce-speckit-read` com os times (via secret manager da empresa, não em texto claro).

---

## Resumo visual — sequência completa

```
VOCÊ FAZ (manual)                    AUTOMÁTICO (CI)
─────────────────────────────────────────────────────
Criar org clean-environment
Criar repo spec-kit-private
Criar PAT ce-release-bot-token
Criar PAT ce-speckit-read
Adicionar secret no repo
Editar release.yml (token)
git push -u origin main           → validate-package.yml roda
git tag core-v1.0.0 + push        → release.yml empacota, atualiza catálogo
git tag tools-v1.0.0 + push       → release.yml empacota, atualiza catálogo
Verificar catálogos (checksums OK?)
Testar projeto piloto localmente
Instalar feature-pr-check.yml      → feature-pr-check.yml roda em cada PR
  nos repos dos times
Distribuir token de leitura
Treinamento dos times (1h)
```

---

## Atualizações futuras do pacote

Quando precisar atualizar um template, um comando ou a knowledge base:

1. Faça as alterações nos arquivos
2. Atualize a versão em `preset.yml` ou `extension.yml` (ex: `1.0.0` → `1.1.0`)
3. Crie a PR, aguarde `validate-package.yml` passar, faça merge
4. Crie a tag:

```bash
git tag clean-environment-seguranca-core-v1.1.0
git push origin clean-environment-seguranca-core-v1.1.0
```

Os times atualizam rodando:

```bash
specify preset update clean-environment-seguranca-core
specify extension update clean-environment-seguranca-tools
```

---

**Fim do guia.** Em caso de dúvidas, consulte `docs/04-FAQ.md`.
