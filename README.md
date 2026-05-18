# Clean Environment — Spec Kit Seguro

Pacote oficial da **Clean Environment** que integra os princípios de segurança de dados não-negociáveis da empresa ao fluxo do [Spec Kit](https://github.com/github/spec-kit) (Spec-Driven Development com agentes de IA).

---

## 🚀 Início rápido (Windows)

### 1 — Clone este repositório uma única vez

```powershell
git clone https://github.com/clean-environment/spec-kit-private.git "$HOME\.speckit-ce"
```

> Substitua a URL pelo caminho real do repositório privado da empresa quando disponível.
> Enquanto isso, use o caminho local da pasta na sua máquina.

### 2 — Instale o Spec Kit CLI (uma única vez por máquina)

```powershell
# Instalar uv (gerenciador de pacotes Python)
winget install astral-sh.uv

# Instalar o Spec Kit CLI
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v0.8.11

# Verificar
specify version
```

### 3 — Crie um projeto novo com segurança embutida

```powershell
# Navegue até onde você quer criar o projeto
cd C:\Projetos

# Rode o script de setup (substitua pelo caminho onde clonou o repo)
powershell -ExecutionPolicy Bypass -File "$HOME\.speckit-ce\setup.ps1" meu-projeto
```

Pronto. O script cria a pasta do projeto, instala o preset e a extension automaticamente.

### 4 — Abra o agente e siga os próximos passos

```powershell
cd meu-projeto
claude  # ou o agente que você usa
```

Dentro do agente, na ordem:

```
/speckit.security-context    ← define tipo de projeto, dados e compliance (5 min)
/speckit.constitution         ← gera a constituição com os 6 artigos de segurança
/speckit.security-setup       ← instala .gitignore, scripts e proteções de ambiente
```

A partir daí, use o ciclo normal de features conforme `docs/01-COMECE-AQUI.md`.

---

### Parâmetros do setup.ps1

| Parâmetro | Padrão | Descrição |
|---|---|---|
| `ProjectName` (posicional) | — | Nome do projeto (obrigatório) |
| `-Integration` | `claude` | Agente: `claude`, `codex`, `cursor-agent`, `gemini`, `copilot` |
| `-Destination` | Diretório atual | Pasta onde o projeto será criado |

Exemplos:

```powershell
# Projeto com Gemini CLI
.\setup.ps1 meu-projeto -Integration gemini

# Projeto em pasta específica
.\setup.ps1 meu-projeto -Destination C:\Projetos\2026
```

---

### Como manter o pacote atualizado

Quando os templates ou a knowledge base forem atualizados, cada desenvolvedor roda:

```powershell
cd "$HOME\.speckit-ce"
git pull
```

Não é preciso reinstalar nada — o Spec Kit referencia a pasta local diretamente.

---

## O que está aqui

```
clean-environment-seguranca/
├── clean-environment-seguranca-core/         # 📦 PRESET — piso obrigatório
│   ├── preset.yml                            #     Manifesto do preset
│   ├── README.md                             #     Como instalar e usar
│   └── templates/                            #     Substituem o core do Spec Kit
│       ├── constitution-template.md          #       Constituição em 6 artigos temáticos
│       ├── spec-template.md                  #       Spec + Security & Privacy Impact obrigatório
│       ├── plan-template.md                  #       Plan + Security Gates + Compliance Gates
│       ├── tasks-template.md                 #       Tasks + bloco [SEC] transversal
│       └── checklist-template.md             #       12 grupos do CHECKLIST-RAPIDO
│
├── clean-environment-seguranca-tools/        # 🧰 EXTENSION — comandos + hooks
│   ├── extension.yml                         #     Manifesto da extension
│   ├── README.md                             #     Comandos, hooks, configuração
│   ├── commands/                             #     4 skills novas
│   │   ├── security-context.md               #       /speckit.security-context
│   │   ├── security-setup.md                 #       /speckit.security-setup
│   │   ├── threat-model.md                   #       /speckit.threat-model
│   │   └── security-audit.md                 #       /speckit.security-audit
│   ├── hooks/                                #     3 hooks automáticos
│   │   ├── before_plan.yml                   #       Bloqueia /speckit.plan se contexto ausente
│   │   ├── before_implement.yml              #       Auditoria design antes do código
│   │   └── after_implement.yml               #       security-check.sh após código gerado
│   ├── knowledge/
│   │   └── vulnerabilities.md                #     KB com 20 padrões (XSS, SQLi, IDOR, SSRF, etc.)
│   └── scripts/templates/                    #     Arquivos copiados por /speckit.security-setup
│       ├── gitignore.txt
│       ├── env.example.txt
│       ├── security-check.sh
│       ├── husky-pre-commit.sh
│       └── readme-security-section.md
│
├── catalogs/                                 # 📚 Distribuição privada
│   ├── preset-catalog.json                   #     JSON consumido pelo Spec Kit (preset)
│   ├── extension-catalog.json                #     JSON consumido pelo Spec Kit (extension)
│   └── README.md                             #     Como hospedar e configurar
│
├── ci/                                       # 🤖 GitHub Actions
│   ├── validate-package.yml                  #     Valida preset/extension em PR
│   ├── release.yml                           #     Empacota, atualiza catálogo, publica release
│   ├── feature-pr-check.yml                  #     Roda em cada projeto consumidor
│   └── README.md                             #     Como instalar nos consumidores
│
└── docs/                                     # 📖 Documentação interna
    ├── 01-COMECE-AQUI.md                     #     Setup inicial em 30 min
    ├── 02-PRIMEIRO-PROJETO.md                #     Passo a passo completo (Photo Albums)
    ├── 03-TREINAMENTO-1H.md                  #     Roteiro de treinamento 1h
    ├── 04-FAQ.md                             #     Perguntas comuns
    └── 05-CONTRIBUTING.md                    #     Como propor mudanças
```

**34 arquivos**, **~5.200 linhas**, **~268 KB**.

## Origem

Este pacote é a integração dos 5 documentos da pasta `Segurança de Dados/` da empresa com o framework Spec Kit. Cada documento foi absorvido — não descartado — em pontos rastreáveis do fluxo:

| Documento original | Onde foi para |
| --- | --- |
| `01 - ROTINA-SEGURANCA-CLAUDE.md` | Constituição (6 artigos) + `/speckit.security-setup` + hooks |
| `02 - KIT-INICIAL-SEGURANCA.md` | `scripts/templates/*` + `/speckit.security-setup` |
| `CHECKLIST-RAPIDO.md` | `checklist-template.md` (12 grupos preservados) |
| `PROMPTS-CLAUDE.md` | SKILL.md de cada comando + `/speckit.threat-model` + `/speckit.security-audit` |
| `VULNERABILIDADES-COMUNS.md` | `knowledge/vulnerabilities.md` (20 entradas) |

## Roll-out

### Fase 1 (1–2 semanas) — Construir e testar em projeto piloto
- ✅ Preset completo (5 templates)
- ✅ Extension com 2 comandos iniciais (`security-context`, `security-setup`)
- ⏭️ Testar em 1 projeto greenfield novo com Claude Code

### Fase 2 (1 semana) — Comandos avançados + multi-agente
- ✅ Comandos `threat-model` e `security-audit`
- ✅ Hooks `before_plan`, `before_implement`, `after_implement`
- ✅ Scripts auxiliares + knowledge base de vulnerabilidades
- ⏭️ Testar em Codex / Cursor / Gemini

### Fase 3 (contínuo) — Distribuição na empresa
- ✅ Catálogo privado (preset-catalog.json, extension-catalog.json)
- ✅ Documentação completa (5 documentos em `docs/`)
- ✅ Workflows CI (validate, release, feature-pr-check)
- ⏭️ Criar repositório `clean-environment/spec-kit-private` no GitHub
- ⏭️ Treinamento dos times (1h por time, roteiro em `docs/03-TREINAMENTO-1H.md`)
- ⏭️ Coleta de feedback quinzenal + iteração

## Próximos passos para você

1. **Criar o repositório privado:** `gh repo create clean-environment/spec-kit-private --private`
2. **Push deste conteúdo:**
   ```bash
   cd clean-environment-seguranca
   git init -b main
   git add .
   git commit -m "feat: Clean Environment Spec Kit security pack v1.0.0"
   git remote add origin https://github.com/clean-environment/spec-kit-private.git
   git push -u origin main
   ```
3. **Configurar secrets do GitHub Actions:**
   - `GH_TOKEN_SPECKIT_PRIVATE` — PAT com escopo `repo` (para CI dos consumidores)
4. **Primeiro release** (cria tarballs e publica no GitHub Releases):
   ```bash
   git tag clean-environment-seguranca-core-v1.0.0
   git tag clean-environment-seguranca-tools-v1.0.0
   git push --tags
   ```
   (O workflow `ci/release.yml` empacota e atualiza os catálogos automaticamente.)
5. **Projeto piloto:** escolha um projeto greenfield e siga `docs/02-PRIMEIRO-PROJETO.md` literalmente.
6. **Treinamento:** após validação no piloto, agende 1h por time conforme `docs/03-TREINAMENTO-1H.md`.

## Suporte

- **Documentação:** `docs/`
- **Issues / PRs:** GitHub no repositório privado
- **Vulnerabilidades:** `security@cleanenvironment.com.br` (substitua pelo email real)
- **Canal de equipe:** `#spec-kit-seguranca` (Slack/Discord/equivalente — definir)

## Licença

Proprietário — Clean Environment. Uso interno.

---

**Versão deste pacote:** 1.0.0
**Spec Kit compatível:** 0.8.11 (testado), `>=0.8.11,<0.9.0` declarado
**Autor:** Equipe de Segurança Corporativa — Clean Environment
**Data:** 2026-05-17
# speckit-clean-environment
