# Clean Environment — Segurança (Core Preset)

Preset oficial da **Clean Environment** que substitui os templates do core do Spec Kit para que toda spec, plan, tasks, constitution e checklist gerados em qualquer projeto da empresa já nasçam com segurança de dados como dimensão obrigatória — não como passo posterior.

## O que este preset faz

| Arquivo do Spec Kit core | É substituído por |
| --- | --- |
| `constitution-template.md` | Constituição da Clean Environment reagrupada em **6 artigos temáticos** (Identidade & Acesso, Integridade de Dados, Resiliência & Operação, Privacidade & Compliance, Cultura & Processo, Governança & Evolução) |
| `spec-template.md` | Spec original + seção obrigatória **Security & Privacy Impact** (dados tratados, permissões, riscos OWASP aplicáveis) |
| `plan-template.md` | Plan original + **Security Gate** + **Compliance Gate** condicional (LGPD/GDPR/PCI-DSS/HIPAA conforme `security-context.md`) |
| `tasks-template.md` | Tasks padrão + tasks transversais **[SEC]** automáticas por user story |
| `checklist-template.md` | Checklist baseado nos **12 grupos** do CHECKLIST-RAPIDO da empresa |

## Instalação

```bash
# Em um projeto novo (greenfield):
specify init meu-projeto --integration claude --preset clean-environment-seguranca-core

# Em um projeto já inicializado com Spec Kit:
specify preset add clean-environment-seguranca-core
```

## Instalação a partir do GitHub privado da empresa

```bash
# Via catálogo privado (recomendado para times):
export SPECKIT_PRESET_CATALOG_URL="https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/catalogs/preset-catalog.json"
specify preset add clean-environment-seguranca-core

# Via URL direta (uso ad-hoc):
specify preset add clean-environment-seguranca-core \
    --from "https://github.com/clean-environment/spec-kit-private/raw/main/clean-environment-seguranca-core.tar.gz"

# Para desenvolvimento local:
specify preset add --dev /caminho/local/clean-environment-seguranca-core
```

## Dependência obrigatória

Este preset é o **piso**. Para o fluxo completo da empresa, instale também a extension:

```bash
specify extension add clean-environment-seguranca-tools
```

A extension adiciona os 4 comandos novos (`/speckit.security-context`, `/speckit.security-setup`, `/speckit.threat-model`, `/speckit.security-audit`) e os 3 hooks automáticos (`before_plan`, `before_implement`, `after_implement`) que tornam o ciclo completo. Sem ela o preset funciona, mas o time precisará lembrar manualmente dos passos de captura de contexto e auditoria.

## Resolução dos template_variables

Os templates deste preset usam marcadores condicionais resolvidos pelo `/speckit.plan` a partir do arquivo `.specify/memory/security-context.md`:

| Variável | Origem |
| --- | --- |
| `compliance_lgpd` | `compliance.lgpd: true/false` no security-context |
| `compliance_gdpr` | `compliance.gdpr: true/false` |
| `compliance_pci_dss` | `compliance.pci_dss: true/false` |
| `compliance_hipaa` | `compliance.hipaa: true/false` |

Sem `security-context.md` preenchido, o plan trata todos os compliance gates como inativos e emite alerta visível recomendando rodar `/speckit.security-context` antes.

## Versionamento e compatibilidade

- `requires.speckit_version: ">=0.8.11,<0.9.0"` — testado em Spec Kit 0.8.11.
- Atualizações deste preset seguem semver:
  - **patch** (1.0.x): correções em wording, novos marcadores OWASP, atualizações de checklist.
  - **minor** (1.x.0): novas seções nos templates, novos compliance gates.
  - **major** (x.0.0): mudança incompatível na constitution ou estrutura dos artefatos — requer revisão de specs/plans existentes.

## Como contribuir

Repositório privado interno: `https://github.com/clean-environment/spec-kit-private`.

Pull requests para este preset passam por:

1. **Aprovação de Security Champion** do time autor.
2. **Aprovação de pelo menos 1 membro da equipe de Segurança Corporativa**.
3. **CI:** instalação automática em projeto piloto + execução do `/speckit.specify → /speckit.plan` sintético + diff dos artefatos gerados antes/depois.

Ver `docs/CONTRIBUTING-PRESET.md` para o processo completo.
