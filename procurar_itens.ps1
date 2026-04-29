Write-Host "--- Procurador de Itens por Texto no Título ---" -ForegroundColor Cyan

# 1. Obter os termos
$termos_str = Read-Host "Digite os termos que deseja procurar (separados por vírgula ou espaço)"

if ([string]::IsNullOrWhiteSpace($termos_str)) {
    Write-Host "AVISO: Nenhum termo fornecido. Encerrando." -ForegroundColor Red
    exit
}

# Extrair termos, remover espaços em branco e duplicatas
$termos = $termos_str -split '[, ]+' | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

if ($termos.Count -eq 0) {
    Write-Host "AVISO: Nenhum termo válido foi identificado. Encerrando." -ForegroundColor Red
    exit
}

Write-Host "Termos a procurar: $($termos -join ', ')" -ForegroundColor Yellow

# 2. Obter o local de busca
$source_path = Read-Host "Digite o caminho completo da pasta ou disco onde deseja procurar (Ex: C:\ ou Y:\Pasta)"

if (-Not (Test-Path -Path $source_path)) {
    Write-Host "AVISO: O caminho '$source_path' não existe ou não está acessível." -ForegroundColor Red
    exit
}

# Garante barra no final para evitar falhas no CMD do Windows
if (-not $source_path.EndsWith('\')) {
    $source_path += "\"
}

# 3. Varredura
Write-Host "`nIniciando a busca em $source_path ..." -ForegroundColor Cyan
Write-Host "Este processo buscará os termos APENAS nos TÍTULOS dos arquivos e pastas." -ForegroundColor Yellow
Write-Host "Extensões serão ignoradas!" -ForegroundColor Yellow

$encontrados = @{}
foreach ($termo in $termos) {
    $encontrados[$termo] = @()
}

$counter = 0

# Usamos dir /s /b nativamente por ser imensamente mais rápido que o Get-ChildItem para discos inteiros/grandes volumes.
# Retorna todos os caminhos (arquivos e pastas).
cmd.exe /c "dir /s /b `"$source_path*`" 2>nul" | ForEach-Object {
    $file_path = $_
    $counter++
    
    # PROGRESSO: Aviso para o usuário ver que não travou
    if ($counter % 2000 -eq 0) {
        Write-Host "PROGRESSO: Processando... $counter itens verificados até agora." -ForegroundColor DarkGray
    }

    try {
        # Pega apenas o nome do arquivo, removendo a extensão. Isso atende ao pedido de não verificar a extensão.
        $title_only = [System.IO.Path]::GetFileNameWithoutExtension($file_path)

        foreach ($termo in $termos) {
            # Verifica se o termo informado pelo usuário está contido APENAS no título
            if ($title_only.ToLower().Contains($termo.ToLower())) {
                
                # Evitar mostrar itens duplicados caso ocorra repasses
                if (-not ($encontrados[$termo] -contains $file_path)) {
                    $encontrados[$termo] += $file_path
                    
                    # SUCESSO OCORRIDO AGORA:
                    Write-Host " -> SUCESSO! Encontrei o termo '$termo' neste título!" -ForegroundColor Green
                    Write-Host "    Caminho: $file_path" -ForegroundColor Green
                }
            }
        }
    }
    catch {
        # Ignora arquivos inválidos corrompidos ou erros de split para não parar a pesquisa
    }
}

Write-Host "`n=== Busca concluída! Total de itens escaneados: $counter ===" -ForegroundColor Cyan

# 4. Resumo Final (Avisos de Certo / Não Certo)
Write-Host "`n--- RESULTADO FINAL ---" -ForegroundColor Cyan

foreach ($termo in $termos) {
    $qdt = $encontrados[$termo].Count
    if ($qdt -gt 0) {
        # QUANDO DER CERTO
        Write-Host "SUCESSO: O termo '$termo' foi encontrado em $qdt item(ns)." -ForegroundColor Green
    } else {
        # QUANDO NÃO DER CERTO / NÃO ENCONTRAR
        Write-Host "NÃO ENCONTRADO: O termo '$termo' NÃO foi achado em lugar nenhum nesta pasta." -ForegroundColor Red
    }
}
