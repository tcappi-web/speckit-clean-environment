# 🚀 Comece Aqui — Spec Kit + Segurança Clean Environment

Bem-vindo! Este guia tira você de **zero** até **primeira feature segura entregue** em aproximadamente 30 minutos.

## Por que este pacote existe

A Clean Environment adotou o **Spec Kit** como ferramenta padrão de desenvolvimento com agentes de IA. Para garantir que segurança de dados não seja "etapa final esquecida" e sim **parte estrutural** de cada feature, criamos:

- **Preset:** `clean-environment-seguranca-core` — substitui templates do Spec Kit para que toda spec, plan, tasks e constitution já nasça com segurança costurada.
- **Extension:** `clean-environment-seguranca-tools` — adiciona 4 comandos novos e 3 hooks automáticos que cobrem captura de contexto, threat modeling e auditoria.

Os 5 documentos originais da pasta "Segurança de Dados" (rotina, kit inicial, checklist, prompts, vulnerabilidades) **estão integralmente cobertos** — não foram descartados, foram absorvidos em pontos rastreáveis do fluxo.

## Pré-requisitos

- **Python 3.11+**
- **uv** ([install uv](https://docs.astral.sh/uv/)) ou **pipx**
- **Git**
- **Um agente de IA suportado:** Claude Code (recomendado), Codex CLI, Cursor, Gemini CLI, GitHub Copilot, ou outros
- **GitHub PAT** com acesso ao repositório privado `clean-environment/spec-kit-private`

## Setup único por desenvolvedor (5 min)

```bash
# 1. Instalar Spec Kit CLI
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v0.8.11

# 2. Configurar autenticação GitHub para repo privado
gh auth login --scopes repo

# 3. Apontar Spec Kit para os catálogos privados da Clean Environment
# Adicione ao seu ~/.bashrc, ~/.zshrc ou equivalente:
export SPECKIT_PRESET_CATALOG_URL="https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/catalogs/preset-catalog.json"
export SPECKIT_CATALOG_URL="https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/catalogs/extension-catalog.json"

# 4. Verificar
specify version
specify integration list
specify preset search clean-environment
```

## Início de um projeto novo (15 min)

```bash
# 1. Criar projeto com o preset da Clean Environment
specify init meu-projeto \
    --integration claude \
    --preset clean-environment-seguranca-core
cd meu-projeto

# 2. Instalar a extension de tools de segurança
specify extension add clean-environment-seguranca-tools

# 3. Abrir o agente (exemplo Claude Code)
claude

# 4. Dentro do agente, rodar a sequência inicial:
/speckit.security-context           # Q&A guiada de contexto (5 min)
/speckit.constitution               # Gera constitution com 6 artigos (1 min)
/speckit.security-setup             # Instala .gitignore, scripts, husky (2 min)
```

A partir daqui o projeto está pronto. Toda feature segue o ciclo abaixo.

## Ciclo de uma feature (varia conforme tamanho)

```bash
# Dentro do agente, na branch principal do projeto:

/speckit.specify "Descrição da feature em linguagem natural..."

# Spec Kit cria branch 001-nome-feature e specs/001-nome-feature/spec.md
# A spec já vem com seção 'Security & Privacy Impact' obrigatória.

/speckit.clarify                    # Reduz ambiguidades
/speckit.checklist                  # Valida qualidade da spec
/speckit.threat-model               # Gera STRIDE da feature
/speckit.plan "Stack escolhida..."  # Plan com Security Gates
/speckit.tasks                      # Gera tasks + tasks [SEC] transversais
/speckit.analyze                    # Consistência cruzada
# (hook before_implement chama /speckit.security-audit automaticamente)
/speckit.implement                  # Executa as tasks
# (hook after_implement roda security-check.sh automaticamente)
```

Para PR/release:

```bash
# Fora do agente:
git push origin 001-nome-feature
# Abrir PR no GitHub — o workflow ci/feature-pr-check.yml roda automaticamente.
```

## Multi-agente

Se o seu time usa outro agente, troque `--integration claude` por um dos suportados:

| Agente | `--integration` |
| --- | --- |
| Claude Code | `claude` |
| Codex CLI | `codex` |
| Cursor | `cursor-agent` |
| Gemini CLI | `gemini` |
| GitHub Copilot | `copilot` |
| Genérico | `generic --integration-options="--commands-dir <path>"` |

A invocação dos comandos muda ligeiramente:
- Claude/Cursor/Gemini/Copilot: `/speckit.security-audit`
- Codex CLI: `$speckit-security-audit`

## Comandos disponíveis (resumo)

| Comando | Quando | Frequência |
| --- | --- | --- |
| `/speckit.security-context` | Início do projeto, ou quando contexto muda | Raro (1× por projeto) |
| `/speckit.constitution` | Início do projeto | 1× por projeto |
| `/speckit.security-setup` | Após constitution | 1× por projeto |
| `/speckit.specify` | Cada feature nova | Por feature |
| `/speckit.clarify` | Após specify | Por feature |
| `/speckit.checklist` | Após clarify | Por feature |
| `/speckit.threat-model` | Após clarify, antes de plan | Por feature (especialmente crítica/alta) |
| `/speckit.plan` | Após threat-model | Por feature |
| `/speckit.tasks` | Após plan | Por feature |
| `/speckit.analyze` | Após tasks | Por feature |
| `/speckit.security-audit` | Antes de implement (auto) e antes de release (manual) | 2+ × por feature |
| `/speckit.implement` | Após audit | Por feature |

## Próximos passos

1. **Leia:** `docs/02-PRIMEIRO-PROJETO.md` — passo-a-passo detalhado com prints e exemplos reais.
2. **Treine:** `docs/03-TREINAMENTO-1H.md` — agenda de 1h para conduzir treinamento de time.
3. **Resolva problemas:** `docs/04-FAQ.md` — perguntas comuns.
4. **Contribua:** `docs/05-CONTRIBUTING.md` — como propor mudanças nos templates, knowledge base e comandos.
