#Requires -Version 5.1
<#
.SYNOPSIS
    Cria um projeto Spec Kit com os padrões de segurança da Clean Environment.

.DESCRIPTION
    Inicializa um projeto com o Spec Kit, instala o preset de segurança
    e a extension de ferramentas da Clean Environment.

.PARAMETER ProjectName
    Nome do projeto a criar. Uma pasta com esse nome será criada no diretório atual.

.PARAMETER Integration
    Agente de IA a usar. Padrão: claude
    Opções: claude, codex, cursor-agent, gemini, copilot, generic

.PARAMETER Destination
    Pasta onde o projeto será criado. Padrão: diretório atual.

.EXAMPLE
    .\setup.ps1 meu-projeto

.EXAMPLE
    .\setup.ps1 meu-projeto -Integration gemini

.EXAMPLE
    .\setup.ps1 meu-projeto -Destination C:\Projetos
#>

param(
    [Parameter(Position = 0)]
    [string]$ProjectName,

    [Parameter()]
    [ValidateSet("claude", "codex", "cursor-agent", "gemini", "copilot", "generic")]
    [string]$Integration = "claude",

    [Parameter()]
    [string]$Destination = (Get-Location).Path
)

# ─── Cores ───────────────────────────────────────────────────────────────────
function Write-Step  { param($msg) Write-Host "`n  ▶ $msg" -ForegroundColor Cyan }
function Write-OK    { param($msg) Write-Host "  ✅ $msg" -ForegroundColor Green }
function Write-Warn  { param($msg) Write-Host "  ⚠  $msg" -ForegroundColor Yellow }
function Write-Fail  { param($msg) Write-Host "`n  ❌ $msg" -ForegroundColor Red }

# ─── Banner ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor DarkCyan
Write-Host "  ║   Clean Environment — Spec Kit Security Setup   ║" -ForegroundColor DarkCyan
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor DarkCyan
Write-Host ""

# ─── Pedir nome do projeto se não foi passado ─────────────────────────────────
if (-not $ProjectName) {
    $ProjectName = Read-Host "  Nome do projeto"
    if (-not $ProjectName) {
        Write-Fail "Nome do projeto é obrigatório. Exemplo: .\setup.ps1 meu-projeto"
        exit 1
    }
}

# ─── Validar nome (sem espaços, sem caracteres especiais) ─────────────────────
if ($ProjectName -match '[^\w\-\.]') {
    Write-Fail "Nome do projeto não pode ter espaços ou caracteres especiais. Use letras, números, hífens e pontos."
    exit 1
}

# ─── Caminhos ─────────────────────────────────────────────────────────────────
$ScriptDir  = $PSScriptRoot
$PresetDir  = Join-Path $ScriptDir "clean-environment-seguranca-core"
$ToolsDir   = Join-Path $ScriptDir "clean-environment-seguranca-tools"
$ProjectDir = Join-Path $Destination $ProjectName

# ─── Pré-requisitos ──────────────────────────────────────────────────────────
Write-Step "Verificando pré-requisitos..."

# specify CLI
if (-not (Get-Command specify -ErrorAction SilentlyContinue)) {
    Write-Fail "O CLI 'specify' não foi encontrado."
    Write-Host ""
    Write-Host "  Instale com:" -ForegroundColor Yellow
    Write-Host "    uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v0.8.11" -ForegroundColor White
    Write-Host ""
    Write-Host "  Se não tiver uv:" -ForegroundColor Yellow
    Write-Host "    winget install astral-sh.uv" -ForegroundColor White
    exit 1
}
Write-OK "specify CLI encontrado: $(specify version 2>&1 | Select-Object -First 1)"

# Preset
if (-not (Test-Path $PresetDir)) {
    Write-Fail "Preset não encontrado em: $PresetDir"
    Write-Host "  Certifique-se de que está rodando este script a partir da pasta clonada do pacote." -ForegroundColor Yellow
    exit 1
}
Write-OK "Preset encontrado: $PresetDir"

# Extension
if (-not (Test-Path $ToolsDir)) {
    Write-Fail "Extension não encontrada em: $ToolsDir"
    exit 1
}
Write-OK "Extension encontrada: $ToolsDir"

# Projeto já existe?
if (Test-Path $ProjectDir) {
    Write-Warn "A pasta '$ProjectDir' já existe."
    $resp = Read-Host "  Continuar mesmo assim? (s/N)"
    if ($resp -notmatch '^[sS]') {
        Write-Host "  Cancelado." -ForegroundColor Gray
        exit 0
    }
}

# ─── Criar projeto ───────────────────────────────────────────────────────────
Write-Step "Criando projeto '$ProjectName' com integration '$Integration'..."
specify init $ProjectName --integration $Integration --ignore-agent-tools --here:$false 2>&1 | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }

if (-not (Test-Path $ProjectDir)) {
    # specify init pode criar na pasta com o próprio nome — ajusta caminho
    $ProjectDir = Join-Path (Get-Location).Path $ProjectName
}

if (-not (Test-Path $ProjectDir)) {
    Write-Fail "O projeto não foi criado. Verifique o output acima."
    exit 1
}

Write-OK "Projeto criado em: $ProjectDir"

# ─── Entrar na pasta do projeto ───────────────────────────────────────────────
Push-Location $ProjectDir

try {
    # ─── Instalar preset ─────────────────────────────────────────────────────
    Write-Step "Instalando preset de segurança (clean-environment-seguranca-core)..."
    specify preset add --dev $PresetDir 2>&1 | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
    Write-OK "Preset instalado"

    # ─── Instalar extension ──────────────────────────────────────────────────
    Write-Step "Instalando extension de ferramentas (clean-environment-seguranca-tools)..."
    specify extension add --dev $ToolsDir 2>&1 | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
    Write-OK "Extension instalada"

    # ─── Verificar artefatos ─────────────────────────────────────────────────
    Write-Step "Verificando instalação..."
    $ok = $true

    $templates = @("constitution-template.md","spec-template.md","plan-template.md","tasks-template.md","checklist-template.md")
    foreach ($tpl in $templates) {
        if (-not (Test-Path ".specify\templates\$tpl")) {
            Write-Warn "Template não encontrado: $tpl"
            $ok = $false
        }
    }

    if (-not (Test-Path ".specify\extensions\clean-environment-seguranca-tools")) {
        Write-Warn "Pasta da extension não encontrada em .specify\extensions\"
        $ok = $false
    }

    if ($ok) {
        Write-OK "Todos os artefatos instalados corretamente"
    }

} finally {
    Pop-Location
}

# ─── Resumo final ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║   ✅ Projeto pronto!                             ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Projeto: " -NoNewline -ForegroundColor Gray
Write-Host $ProjectDir -ForegroundColor White
Write-Host "  Agente:  " -NoNewline -ForegroundColor Gray
Write-Host $Integration -ForegroundColor White
Write-Host ""
Write-Host "  Próximos passos (dentro do agente):" -ForegroundColor Yellow
Write-Host "    1. cd $ProjectName" -ForegroundColor White
Write-Host "    2. Abra o agente  (ex: claude)" -ForegroundColor White
Write-Host "    3. /speckit.security-context   ← define tipo de projeto e compliance" -ForegroundColor White
Write-Host "    4. /speckit.constitution        ← gera a constituição com segurança" -ForegroundColor White
Write-Host "    5. /speckit.security-setup      ← instala .gitignore, scripts, husky" -ForegroundColor White
Write-Host ""
Write-Host "  Documentação: $ScriptDir\docs\01-COMECE-AQUI.md" -ForegroundColor DarkGray
Write-Host ""
