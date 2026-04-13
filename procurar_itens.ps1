Write-Host "--- Verificador de Itens (Asset IDs) ---" -ForegroundColor Cyan

# 1. Obter os Asset IDs
$asset_ids_str = Read-Host "Digite os Asset IDs que deseja procurar (separados por virgula ou espaco)"

if ([string]::IsNullOrWhiteSpace($asset_ids_str)) {
    Write-Host "Nenhum Asset ID fornecido. Encerrando." -ForegroundColor Red
    exit
}

# Transformar a string recebida num array dividindo por virgula ou espaco e removendo vazios
$asset_ids_raw = $asset_ids_str -split '[, ]+' | Where-Object { $_ -ne '' }

# Remover zeros à esquerda (ex: 0123 ou 00123 vira 123) para a base da pesquisa
$asset_ids = $asset_ids_raw | ForEach-Object {
    $val = $_ -replace '^0+', ''
    if ($val -eq '') { '0' } else { $val }
} | Select-Object -Unique

if ($asset_ids.Count -eq 0) {
    Write-Host "Nenhum ID valido fornecido. Encerrando." -ForegroundColor Red
    exit
}

Write-Host "Asset IDs a procurar: $($asset_ids -join ', ')" -ForegroundColor Yellow

# 2. Obter o disco de busca
$drive_input = Read-Host "Digite a letra do disco que deseja varrer inteiramente (ex: C ou D)"

# Formatar a entrada do usuario corretamente para o padrao (ex: de "c", "c:" ou "C:\" para "C:\")
if ($drive_input -match '^[a-zA-Z]$') {
    $source_drive = $drive_input + ":\"
}
elseif ($drive_input -match '^[a-zA-Z]:\\?$') {
    $source_drive = $drive_input.Substring(0, 1) + ":\"
}
else {
    Write-Host "Entrada de disco invalida. Use apenas a letra, como C ou D. Encerrando." -ForegroundColor Red
    exit
}

if (-Not (Test-Path -Path $source_drive)) {
    Write-Host "Erro: O disco '$source_drive' nao e valido ou nao esta acessivel." -ForegroundColor Red
    exit
}

# 3. Realizar a busca no disco inteiro (OTIMIZADO)
Write-Host "`nIniciando a varredura OTIMIZADA no disco $source_drive..." -ForegroundColor Cyan
Write-Host "(Desta vez o script fara uma UNICA leitura de arvore para todos os itens, gastando muito menos memoria e prevenindo travamentos em discos dificeis como rede/mapeamentos)`n" -ForegroundColor Yellow

# Dicionario para armazenar os caminhos onde cada asset foi encontrado
$encontrados = @{}
foreach ($asset in $asset_ids) {
    $encontrados[$asset] = @()
}

# Criamos uma expressao regular que checa todos os IDs buscando o numero exato
# (?<![a-zA-Z0-9]) -> garante que não tem NENHUMA letra nem dígito ANTES (ex: evita e459206)
# 0*               -> aceita qualquer quantidade de zeros à esquerda reais no arquivo (ex: 00123)
# (?![a-zA-Z0-9])  -> garante que não tem NENHUMA letra nem dígito DEPOIS
$regex_parts = $asset_ids | ForEach-Object { "(?<![a-zA-Z0-9])0*" + [regex]::Escape($_) + "(?![a-zA-Z0-9])" }
$regex_pattern = $regex_parts -join '|'

# Get-ChildItem ira varrer o disco apenas uma unica vez
# Usamos o pipeline para nao sobrecarregar a memoria guardando tudo de uma vez
Get-ChildItem -Path $source_drive -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
    
    # Se o nome do arquivo der match em ALGUM dos nossos IDs, processamos
    if ($_.Name -match $regex_pattern) {
        $file_name = $_.Name
        $file_path = $_.FullName
        
        # Testamos especificamente para saber de qual ID ele pertence e anexar ao relatorio
        foreach ($asset in $asset_ids) {
            # Confirma match exato isolado para este ID especifico, sem letras encostadas
            $individual_pattern = "(?<![a-zA-Z0-9])0*" + [regex]::Escape($asset) + "(?![a-zA-Z0-9])"
            if ($file_name -match $individual_pattern) {
                $encontrados[$asset] += $file_path
                Write-Host " -> ACHEI ($asset)! Caminho: $file_path" -ForegroundColor Green
            }
        }
    }
}

# 4. Resumo Final da Verificacao
Write-Host "`n--- Relatorio Resumo da Verificacao ---" -ForegroundColor Cyan

$num_faltando = 0

foreach ($asset in $asset_ids) {
    $quantidade_encontrada = $encontrados[$asset].Count
    
    if ($quantidade_encontrada -gt 0) {
        Write-Host "[OK] '$asset': Encontrado em $quantidade_encontrada local(is)." -ForegroundColor Green
    }
    else {
        Write-Host "[X] '$asset': NAO ENCONTRADO em lugar nenhum no disco $source_drive." -ForegroundColor Red
        $num_faltando++
    }
}

if ($num_faltando -eq 0) {
    Write-Host "`n=== Sucesso: TODOS os itens procurados existem no disco! ===" -ForegroundColor Green
}
else {
    Write-Host "`n=== Atencao: $num_faltando item(ns) NÃO foram achados neste disco. ===" -ForegroundColor Yellow
}
