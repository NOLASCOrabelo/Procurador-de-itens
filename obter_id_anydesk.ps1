# Script para obter ID do AnyDesk de uma máquina específica

param(
    [string]$ComputerName = "localhost"
)

Write-Host "=== Obter ID do AnyDesk ===" -ForegroundColor Cyan
Write-Host ""

if ($ComputerName -eq "localhost") {
    Write-Host "Buscando ID do AnyDesk LOCAL..." -ForegroundColor Yellow
} else {
    Write-Host "Buscando ID do AnyDesk em: $ComputerName" -ForegroundColor Yellow
}

Write-Host ""

# Locais onde o ID pode estar
$paths = @(
    "$env:APPDATA\AnyDesk\service.conf",
    "$env:PROGRAMDATA\AnyDesk\service.conf",
    "C:\ProgramData\AnyDesk\service.conf",
    "$env:APPDATA\AnyDesk\user.conf",
    "$env:LOCALAPPDATA\AnyDesk\service.conf"
)

$idEncontrado = $false

foreach ($path in $paths) {
    if (Test-Path $path) {
        Write-Host "Verificando: $path" -ForegroundColor DarkGray
        
        $content = Get-Content $path -ErrorAction SilentlyContinue
        foreach ($line in $content) {
            if ($line -match 'ad\.anynet\.id=(\d+)') {
                $id = $matches[1]
                $formattedID = $id -replace '(\d{1})(\d{3})(\d{3})(\d{3})', '$1 $2 $3 $4'
                
                Write-Host ""
                Write-Host "OK ID ENCONTRADO!" -ForegroundColor Green
                Write-Host ""
                Write-Host "  AnyDesk ID: $formattedID" -ForegroundColor White -BackgroundColor DarkGreen
                Write-Host "  (Formato sem espacos: $id)" -ForegroundColor DarkGray
                Write-Host "  Arquivo: $path" -ForegroundColor DarkGray
                Write-Host ""
                
                $idEncontrado = $true
                break
            }
        }
        
        if ($idEncontrado) { break }
    }
}

if (-not $idEncontrado) {
    Write-Host ""
    Write-Host "X AnyDesk nao encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifique se:" -ForegroundColor Yellow
    Write-Host "  1. AnyDesk esta instalado" -ForegroundColor Yellow
    Write-Host "  2. AnyDesk foi executado pelo menos uma vez" -ForegroundColor Yellow
    Write-Host "  3. Voce tem permissoes para acessar os arquivos" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host ""
Write-Host "Pressione qualquer tecla para sair..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
