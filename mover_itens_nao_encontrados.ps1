Write-Host "=== Mover Itens NAO Encontrados (Irrelevantes) ===" -ForegroundColor Cyan
Write-Host ""

# 1. Obter os termos que DEVEM existir (os relevantes)
$termos_str = Read-Host "Digite os termos RELEVANTES que voce procurou (separados por virgula ou espaco)"

if ([string]::IsNullOrWhiteSpace($termos_str)) {
    Write-Host "AVISO: Nenhum termo fornecido. Encerrando." -ForegroundColor Red
    exit
}

# Extrair termos
$termos = $termos_str -split '[, ]+' | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

if ($termos.Count -eq 0) {
    Write-Host "AVISO: Nenhum termo valido foi identificado. Encerrando." -ForegroundColor Red
    exit
}

Write-Host "Termos RELEVANTES: $($termos -join ', ')" -ForegroundColor Yellow
Write-Host ""

# 2. Obter a pasta de origem (onde estão os 80 itens)
$source_path = Read-Host "Digite o caminho da pasta ORIGEM (onde estao os itens)"

if (-Not (Test-Path -Path $source_path)) {
    Write-Host "AVISO: O caminho '$source_path' nao existe ou nao esta acessivel." -ForegroundColor Red
    exit
}

# 3. Obter a pasta de destino (para onde mover os irrelevantes)
$dest_path = Read-Host "Digite o caminho da pasta DESTINO (para onde mover os irrelevantes)"

if (-Not (Test-Path -Path $dest_path)) {
    Write-Host "A pasta destino nao existe. Deseja cria-la? (S/N)" -ForegroundColor Yellow
    $criar = Read-Host
    if ($criar -eq 'S' -or $criar -eq 's') {
        New-Item -Path $dest_path -ItemType Directory -Force | Out-Null
        Write-Host "Pasta criada: $dest_path" -ForegroundColor Green
    } else {
        Write-Host "Operacao cancelada." -ForegroundColor Red
        exit
    }
}

Write-Host ""
Write-Host "=== CONFIGURACAO ===" -ForegroundColor Cyan
Write-Host "Pasta ORIGEM: $source_path" -ForegroundColor White
Write-Host "Pasta DESTINO: $dest_path" -ForegroundColor White
Write-Host "Termos RELEVANTES: $($termos -join ', ')" -ForegroundColor White
Write-Host ""
Write-Host "ATENCAO: Itens que NAO contenham nenhum dos termos acima serao MOVIDOS para o destino!" -ForegroundColor Yellow
Write-Host ""

$confirma = Read-Host "Deseja continuar? (S/N)"
if ($confirma -ne 'S' -and $confirma -ne 's') {
    Write-Host "Operacao cancelada pelo usuario." -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "Iniciando analise..." -ForegroundColor Cyan
Write-Host ""

# 4. Listar todos os itens da pasta origem (apenas nivel 1, nao recursivo)
$todos_itens = Get-ChildItem -Path $source_path -File -ErrorAction SilentlyContinue

if ($todos_itens.Count -eq 0) {
    Write-Host "AVISO: Nenhum arquivo encontrado na pasta origem." -ForegroundColor Yellow
    exit
}

Write-Host "Total de itens na pasta origem: $($todos_itens.Count)" -ForegroundColor Cyan
Write-Host ""

# 5. Separar itens RELEVANTES e IRRELEVANTES
$relevantes = @()
$irrelevantes = @()

foreach ($item in $todos_itens) {
    $title_only = [System.IO.Path]::GetFileNameWithoutExtension($item.Name)
    $eh_relevante = $false
    
    foreach ($termo in $termos) {
        if ($title_only.ToLower().Contains($termo.ToLower())) {
            $eh_relevante = $true
            break
        }
    }
    
    if ($eh_relevante) {
        $relevantes += $item
    } else {
        $irrelevantes += $item
    }
}

Write-Host "=== ANALISE COMPLETA ===" -ForegroundColor Cyan
Write-Host "Itens RELEVANTES (ficarao na origem): $($relevantes.Count)" -ForegroundColor Green
Write-Host "Itens IRRELEVANTES (serao movidos): $($irrelevantes.Count)" -ForegroundColor Yellow
Write-Host ""

if ($irrelevantes.Count -eq 0) {
    Write-Host "Nenhum item irrelevante encontrado. Nada a mover!" -ForegroundColor Green
    exit
}

# 6. Mostrar preview dos itens que serão movidos
Write-Host "=== PREVIEW: Itens que serao MOVIDOS ===" -ForegroundColor Yellow
$preview_count = [Math]::Min(10, $irrelevantes.Count)
for ($i = 0; $i -lt $preview_count; $i++) {
    Write-Host "  - $($irrelevantes[$i].Name)" -ForegroundColor DarkGray
}
if ($irrelevantes.Count -gt 10) {
    Write-Host "  ... e mais $($irrelevantes.Count - 10) itens" -ForegroundColor DarkGray
}
Write-Host ""

$confirma_final = Read-Host "Confirma mover $($irrelevantes.Count) itens para '$dest_path'? (S/N)"
if ($confirma_final -ne 'S' -and $confirma_final -ne 's') {
    Write-Host "Operacao cancelada pelo usuario." -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "Movendo itens..." -ForegroundColor Cyan
Write-Host ""

# 7. Mover os itens irrelevantes
$movidos = 0
$erros = 0

foreach ($item in $irrelevantes) {
    try {
        $dest_file = Join-Path -Path $dest_path -ChildPath $item.Name
        
        # Se já existe no destino, adiciona sufixo
        if (Test-Path -Path $dest_file) {
            $base_name = [System.IO.Path]::GetFileNameWithoutExtension($item.Name)
            $extension = $item.Extension
            $counter = 1
            do {
                $dest_file = Join-Path -Path $dest_path -ChildPath "$base_name`_$counter$extension"
                $counter++
            } while (Test-Path -Path $dest_file)
        }
        
        Move-Item -Path $item.FullName -Destination $dest_file -Force
        $movidos++
        
        if ($movidos % 10 -eq 0) {
            Write-Host "Progresso: $movidos/$($irrelevantes.Count) itens movidos..." -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host "ERRO ao mover: $($item.Name) - $($_.Exception.Message)" -ForegroundColor Red
        $erros++
    }
}

Write-Host ""
Write-Host "=== OPERACAO CONCLUIDA ===" -ForegroundColor Cyan
Write-Host "Itens movidos com sucesso: $movidos" -ForegroundColor Green
Write-Host "Itens que permaneceram (relevantes): $($relevantes.Count)" -ForegroundColor Green
if ($erros -gt 0) {
    Write-Host "Erros durante a movimentacao: $erros" -ForegroundColor Red
}
Write-Host ""
Write-Host "Pasta ORIGEM: $source_path" -ForegroundColor White
Write-Host "Pasta DESTINO: $dest_path" -ForegroundColor White
Write-Host ""
