Write-Host "=== Procurador e Organizador de Itens ===" -ForegroundColor Cyan
Write-Host "Este script procura itens relevantes e move os irrelevantes para outra pasta." -ForegroundColor Yellow
Write-Host ""

# ═══════════════════════════════════════════════════════════════
# ETAPA 1: PROCURAR ITENS RELEVANTES
# ═══════════════════════════════════════════════════════════════

Write-Host "--- ETAPA 1: PROCURAR ITENS RELEVANTES ---" -ForegroundColor Cyan
Write-Host ""

# 1. Obter os termos
$termos_str = Read-Host "Digite os termos que deseja procurar (separados por virgula ou espaco)"

if ([string]::IsNullOrWhiteSpace($termos_str)) {
    Write-Host "AVISO: Nenhum termo fornecido. Encerrando." -ForegroundColor Red
    exit
}

# Extrair termos, remover espaços em branco e duplicatas
$termos = $termos_str -split '[, ]+' | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

if ($termos.Count -eq 0) {
    Write-Host "AVISO: Nenhum termo valido foi identificado. Encerrando." -ForegroundColor Red
    exit
}

Write-Host "Termos a procurar: $($termos -join ', ')" -ForegroundColor Yellow
Write-Host ""

# 2. Obter o local de busca
$source_path = Read-Host "Digite o caminho completo da pasta onde deseja procurar (Ex: C:\Pasta)"

if (-Not (Test-Path -Path $source_path)) {
    Write-Host "AVISO: O caminho '$source_path' nao existe ou nao esta acessivel." -ForegroundColor Red
    exit
}

# Garante barra no final
if (-not $source_path.EndsWith('\')) {
    $source_path += "\"
}

# 3. Varredura
Write-Host ""
Write-Host "Iniciando a busca em $source_path ..." -ForegroundColor Cyan
Write-Host "Buscando os termos APENAS nos TITULOS dos arquivos e pastas." -ForegroundColor Yellow
Write-Host "Extensoes serao ignoradas!" -ForegroundColor Yellow
Write-Host ""

$encontrados_paths = @()
$todos_itens = @()
$counter = 0

# Lista todos os arquivos da pasta (apenas nível 1)
$todos_arquivos = Get-ChildItem -Path $source_path -File -ErrorAction SilentlyContinue

Write-Host "Total de arquivos na pasta: $($todos_arquivos.Count)" -ForegroundColor Cyan
Write-Host ""

foreach ($arquivo in $todos_arquivos) {
    $counter++
    $file_path = $arquivo.FullName
    $todos_itens += $file_path
    
    # Progresso
    if ($counter % 50 -eq 0) {
        Write-Host "PROGRESSO: Processando... $counter/$($todos_arquivos.Count) itens verificados." -ForegroundColor DarkGray
    }

    try {
        # Pega apenas o nome do arquivo, removendo a extensão
        $title_only = [System.IO.Path]::GetFileNameWithoutExtension($file_path)

        $encontrou = $false
        foreach ($termo in $termos) {
            # Verifica se o termo está contido no título
            if ($title_only.ToLower().Contains($termo.ToLower())) {
                if (-not ($encontrados_paths -contains $file_path)) {
                    $encontrados_paths += $file_path
                    $encontrou = $true
                    
                    Write-Host " -> ENCONTRADO! Termo '$termo' no arquivo: $($arquivo.Name)" -ForegroundColor Green
                }
                break
            }
        }
    }
    catch {
        # Ignora erros
    }
}

Write-Host ""
Write-Host "=== Busca concluida! ===" -ForegroundColor Cyan
Write-Host ""

# 4. Resumo da busca
Write-Host "--- RESULTADO DA BUSCA ---" -ForegroundColor Cyan
Write-Host "Total de arquivos na pasta: $($todos_arquivos.Count)" -ForegroundColor White
Write-Host "Arquivos RELEVANTES (encontrados): $($encontrados_paths.Count)" -ForegroundColor Green
Write-Host "Arquivos IRRELEVANTES (nao encontrados): $($todos_arquivos.Count - $encontrados_paths.Count)" -ForegroundColor Yellow
Write-Host ""

# ═══════════════════════════════════════════════════════════════
# ETAPA 2: MOVER ITENS IRRELEVANTES (SE HOUVER)
# ═══════════════════════════════════════════════════════════════

$irrelevantes_count = $todos_arquivos.Count - $encontrados_paths.Count

if ($irrelevantes_count -eq 0) {
    Write-Host "Nenhum arquivo irrelevante encontrado. Todos os arquivos contem os termos procurados!" -ForegroundColor Green
    Write-Host "Operacao concluida." -ForegroundColor Cyan
    exit
}

Write-Host "--- ETAPA 2: MOVER ITENS IRRELEVANTES ---" -ForegroundColor Cyan
Write-Host ""
Write-Host "Foram encontrados $irrelevantes_count arquivos que NAO contem nenhum dos termos." -ForegroundColor Yellow
Write-Host ""

$mover = Read-Host "Deseja mover esses $irrelevantes_count arquivos irrelevantes para outra pasta? (S/N)"

if ($mover -ne 'S' -and $mover -ne 's') {
    Write-Host "Operacao cancelada. Nenhum arquivo foi movido." -ForegroundColor Yellow
    exit
}

Write-Host ""
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
Write-Host "Arquivos a mover: $irrelevantes_count" -ForegroundColor White
Write-Host ""

# Identificar arquivos irrelevantes
$irrelevantes = @()
foreach ($arquivo in $todos_arquivos) {
    if (-not ($encontrados_paths -contains $arquivo.FullName)) {
        $irrelevantes += $arquivo
    }
}

# Preview
Write-Host "=== PREVIEW: Primeiros arquivos que serao MOVIDOS ===" -ForegroundColor Yellow
$preview_count = [Math]::Min(10, $irrelevantes.Count)
for ($i = 0; $i -lt $preview_count; $i++) {
    Write-Host "  - $($irrelevantes[$i].Name)" -ForegroundColor DarkGray
}
if ($irrelevantes.Count -gt 10) {
    Write-Host "  ... e mais $($irrelevantes.Count - 10) arquivos" -ForegroundColor DarkGray
}
Write-Host ""

$confirma = Read-Host "Confirma mover $($irrelevantes.Count) arquivos para '$dest_path'? (S/N)"
if ($confirma -ne 'S' -and $confirma -ne 's') {
    Write-Host "Operacao cancelada." -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "Movendo arquivos..." -ForegroundColor Cyan
Write-Host ""

# Mover os arquivos
$movidos = 0
$erros = 0

foreach ($arquivo in $irrelevantes) {
    try {
        $dest_file = Join-Path -Path $dest_path -ChildPath $arquivo.Name
        
        # Se já existe no destino, adiciona sufixo
        if (Test-Path -Path $dest_file) {
            $base_name = [System.IO.Path]::GetFileNameWithoutExtension($arquivo.Name)
            $extension = $arquivo.Extension
            $counter_suffix = 1
            do {
                $dest_file = Join-Path -Path $dest_path -ChildPath "$base_name`_$counter_suffix$extension"
                $counter_suffix++
            } while (Test-Path -Path $dest_file)
        }
        
        Move-Item -Path $arquivo.FullName -Destination $dest_file -Force
        $movidos++
        
        if ($movidos % 10 -eq 0) {
            Write-Host "Progresso: $movidos/$($irrelevantes.Count) arquivos movidos..." -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host "ERRO ao mover: $($arquivo.Name) - $($_.Exception.Message)" -ForegroundColor Red
        $erros++
    }
}

Write-Host ""
Write-Host "=== OPERACAO CONCLUIDA ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "RESUMO FINAL:" -ForegroundColor White
Write-Host "  Arquivos RELEVANTES (permaneceram na origem): $($encontrados_paths.Count)" -ForegroundColor Green
Write-Host "  Arquivos IRRELEVANTES (movidos para destino): $movidos" -ForegroundColor Green
if ($erros -gt 0) {
    Write-Host "  Erros durante a movimentacao: $erros" -ForegroundColor Red
}
Write-Host ""
Write-Host "Pasta ORIGEM: $source_path" -ForegroundColor White
Write-Host "Pasta DESTINO: $dest_path" -ForegroundColor White
Write-Host ""
Write-Host "Organizacao concluida com sucesso!" -ForegroundColor Green
Write-Host ""
