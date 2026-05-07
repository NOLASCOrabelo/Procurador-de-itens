Write-Host "--- Listador de Arquivos Mais Pesados ---" -ForegroundColor Cyan
Write-Host ""

# 1. Obter o caminho
$source_path = Read-Host "Digite o caminho completo da pasta que deseja analisar (Ex: C:\ ou D:\Dados)"

if (-Not (Test-Path -Path $source_path)) {
    Write-Host "AVISO: O caminho '$source_path' não existe ou não está acessível." -ForegroundColor Red
    exit
}

# 2. Obter quantidade de arquivos a listar
$quantidade = Read-Host "Quantos arquivos mais pesados deseja listar? (padrão: 20)"
if ([string]::IsNullOrWhiteSpace($quantidade) -or $quantidade -notmatch '^\d+$') {
    $quantidade = 20
}

Write-Host ""
Write-Host "Analisando arquivos em $source_path ..." -ForegroundColor Cyan
Write-Host "Isso pode levar alguns minutos dependendo do tamanho do diretório..." -ForegroundColor Yellow
Write-Host "Buscando recursivamente em todos os subdiretórios..." -ForegroundColor Yellow
Write-Host ""

# 3. Buscar e ordenar arquivos por tamanho
Write-Host "Escaneando arquivos..." -ForegroundColor Cyan

$contador_progresso = 0
$arquivos = @()

# Buscar recursivamente TODOS os arquivos
Get-ChildItem -Path $source_path -File -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
    $contador_progresso++
    
    # Mostrar progresso a cada 1000 arquivos
    if ($contador_progresso % 1000 -eq 0) {
        Write-Host "Processados: $contador_progresso arquivos..." -ForegroundColor Yellow
    }
    
    $arquivos += $_
}

Write-Host "Escaneamento concluído! Total de arquivos encontrados: $contador_progresso" -ForegroundColor Green
Write-Host ""

# Ordenar por tamanho e pegar os N maiores
$arquivos = $arquivos | Sort-Object Length -Descending | Select-Object -First $quantidade

# 4. Exibir resultados
Write-Host "=== TOP $quantidade ARQUIVOS MAIS PESADOS ===" -ForegroundColor Cyan
Write-Host ""

$contador = 1
$tamanho_total = 0

foreach ($arquivo in $arquivos) {
    $tamanho_mb = [math]::Round($arquivo.Length / 1MB, 2)
    $tamanho_gb = [math]::Round($arquivo.Length / 1GB, 2)
    $tamanho_total += $arquivo.Length
    
    # Escolher unidade apropriada
    if ($tamanho_gb -ge 1) {
        $tamanho_formatado = "$tamanho_gb GB"
    } else {
        $tamanho_formatado = "$tamanho_mb MB"
    }
    
    Write-Host "[$contador] " -NoNewline -ForegroundColor Yellow
    Write-Host "$tamanho_formatado" -NoNewline -ForegroundColor Green
    Write-Host " - $($arquivo.FullName)" -ForegroundColor White
    
    $contador++
}

Write-Host ""
Write-Host "=== RESUMO ===" -ForegroundColor Cyan
$total_mb = [math]::Round($tamanho_total / 1MB, 2)
$total_gb = [math]::Round($tamanho_total / 1GB, 2)

if ($total_gb -ge 1) {
    Write-Host "Tamanho total dos $quantidade maiores arquivos: $total_gb GB" -ForegroundColor Yellow
} else {
    Write-Host "Tamanho total dos $quantidade maiores arquivos: $total_mb MB" -ForegroundColor Yellow
}

Write-Host ""
