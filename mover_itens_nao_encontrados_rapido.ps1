param(
    [string]$PastaOrigem,
    [string]$PastaDestino,
    [string[]]$Termos
)

Write-Host "=== Mover Itens NAO Encontrados - Modo Rapido ===" -ForegroundColor Cyan
Write-Host ""

# Se não passou parâmetros, pede interativamente
if (-not $PastaOrigem) {
    $PastaOrigem = Read-Host "Digite o caminho da pasta ORIGEM (onde estao os itens)"
}

if (-not $PastaDestino) {
    $PastaDestino = Read-Host "Digite o caminho da pasta DESTINO (para onde mover os irrelevantes)"
}

if (-not $Termos -or $Termos.Count -eq 0) {
    $termos_str = Read-Host "Digite os termos RELEVANTES (separados por virgula ou espaco)"
    $Termos = $termos_str -split '[, ]+' | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
}

# Validações
if (-Not (Test-Path -Path $PastaOrigem)) {
    Write-Host "ERRO: Pasta origem nao existe: $PastaOrigem" -ForegroundColor Red
    exit
}

if (-Not (Test-Path -Path $PastaDestino)) {
    Write-Host "Criando pasta destino: $PastaDestino" -ForegroundColor Yellow
    New-Item -Path $PastaDestino -ItemType Directory -Force | Out-Null
}

Write-Host "Pasta ORIGEM: $PastaOrigem" -ForegroundColor Cyan
Write-Host "Pasta DESTINO: $PastaDestino" -ForegroundColor Cyan
Write-Host "Termos RELEVANTES: $($Termos -join ', ')" -ForegroundColor Cyan
Write-Host ""

# Listar todos os arquivos da origem
$todos = Get-ChildItem -Path $PastaOrigem -File

Write-Host "Total de itens na origem: $($todos.Count)" -ForegroundColor White
Write-Host ""

# Separar relevantes e irrelevantes
$irrelevantes = @()

foreach ($item in $todos) {
    $title = [System.IO.Path]::GetFileNameWithoutExtension($item.Name)
    $eh_relevante = $false
    
    foreach ($termo in $Termos) {
        if ($title.ToLower().Contains($termo.ToLower())) {
            $eh_relevante = $true
            break
        }
    }
    
    if (-not $eh_relevante) {
        $irrelevantes += $item
    }
}

$relevantes_count = $todos.Count - $irrelevantes.Count

Write-Host "Itens RELEVANTES (ficarao): $relevantes_count" -ForegroundColor Green
Write-Host "Itens IRRELEVANTES (serao movidos): $($irrelevantes.Count)" -ForegroundColor Yellow
Write-Host ""

if ($irrelevantes.Count -eq 0) {
    Write-Host "Nenhum item irrelevante encontrado!" -ForegroundColor Green
    exit
}

# Preview
Write-Host "Preview dos primeiros itens a mover:" -ForegroundColor Yellow
$preview = [Math]::Min(5, $irrelevantes.Count)
for ($i = 0; $i -lt $preview; $i++) {
    Write-Host "  - $($irrelevantes[$i].Name)" -ForegroundColor DarkGray
}
if ($irrelevantes.Count -gt 5) {
    Write-Host "  ... e mais $($irrelevantes.Count - 5) itens" -ForegroundColor DarkGray
}
Write-Host ""

$confirma = Read-Host "Mover $($irrelevantes.Count) itens? (S/N)"
if ($confirma -ne 'S' -and $confirma -ne 's') {
    Write-Host "Operacao cancelada." -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "Movendo..." -ForegroundColor Cyan

$movidos = 0
foreach ($item in $irrelevantes) {
    try {
        $dest = Join-Path -Path $PastaDestino -ChildPath $item.Name
        
        # Evitar sobrescrever
        if (Test-Path -Path $dest) {
            $base = [System.IO.Path]::GetFileNameWithoutExtension($item.Name)
            $ext = $item.Extension
            $n = 1
            do {
                $dest = Join-Path -Path $PastaDestino -ChildPath "$base`_$n$ext"
                $n++
            } while (Test-Path -Path $dest)
        }
        
        Move-Item -Path $item.FullName -Destination $dest -Force
        $movidos++
        
        if ($movidos % 10 -eq 0) {
            Write-Host "  $movidos/$($irrelevantes.Count) movidos..." -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host "ERRO: $($item.Name) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== CONCLUIDO ===" -ForegroundColor Green
Write-Host "Movidos: $movidos" -ForegroundColor Green
Write-Host "Permaneceram: $relevantes_count" -ForegroundColor Green
Write-Host ""
