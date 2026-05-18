# Catálogos privados — Clean Environment

Este diretório contém os arquivos JSON que servem como catálogos privados de presets e extensions da empresa, consumidos pelo Spec Kit.

## Arquivos

| Arquivo | Função |
| --- | --- |
| `preset-catalog.json` | Catálogo de presets oficiais (apenas `clean-environment-seguranca-core` por enquanto) |
| `extension-catalog.json` | Catálogo de extensions oficiais (apenas `clean-environment-seguranca-tools` por enquanto) |

## Hospedagem

Os catálogos são servidos via **GitHub Pages** ou **raw.githubusercontent.com** do repositório privado `clean-environment/spec-kit-private`:

```
https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/catalogs/preset-catalog.json
https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/catalogs/extension-catalog.json
```

Acesso aos catálogos exige autenticação GitHub (token com escopo `repo` para repositório privado). Cada desenvolvedor configura uma vez:

```bash
# Configurar GitHub PAT no git
gh auth login --scopes repo

# Configurar SPECKIT_* env vars
export SPECKIT_PRESET_CATALOG_URL="https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/catalogs/preset-catalog.json"
export SPECKIT_CATALOG_URL="https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/catalogs/extension-catalog.json"
```

Adicione essas exports ao seu `~/.bashrc` / `~/.zshrc` / equivalente. Times Windows usam `setx`:

```powershell
setx SPECKIT_PRESET_CATALOG_URL "https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/catalogs/preset-catalog.json"
setx SPECKIT_CATALOG_URL "https://raw.githubusercontent.com/clean-environment/spec-kit-private/main/catalogs/extension-catalog.json"
```

## Checksums

Os arquivos `.tar.gz` referenciados nos catálogos têm seus checksums SHA-256 calculados no momento do release pelo GitHub Action `ci/release.yml` (ver `../ci/`). Antes do primeiro release real, os campos `checksum_sha256` ficam como `[CHECKSUM_GERADO_NO_BUILD]` — a CI substitui automaticamente.

## Atualizando o catálogo

Quando uma nova versão do preset ou da extension é publicada:

1. Bump da versão no `preset.yml` ou `extension.yml`.
2. Tag do release no repositório privado (ex.: `clean-environment-seguranca-core-v1.1.0`).
3. GitHub Action `ci/release.yml` empacota o tar.gz, calcula o checksum, atualiza o catálogo no branch `main`, e cria a release.
4. Times que já têm a versão antiga rodam `specify preset update clean-environment-seguranca-core` ou `specify extension update clean-environment-seguranca-tools`.

## Repositório privado: estrutura sugerida

```
clean-environment/spec-kit-private/
├── catalogs/
│   ├── preset-catalog.json
│   ├── extension-catalog.json
│   └── README.md
├── clean-environment-seguranca-core/       # conteúdo do preset
├── clean-environment-seguranca-tools/      # conteúdo da extension
├── docs/                                    # documentação interna
├── ci/                                      # workflows GitHub Actions
└── README.md                                # entrypoint do repo
```
