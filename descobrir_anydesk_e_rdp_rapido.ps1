param(
    [string]$RedeBase = "192.168.15",
    [int]$InicioIP = 1,
    [int]$FimIP = 254
)

Write-Host "=== Descobridor de AnyDesk e RDP na Rede ===" -ForegroundColor Cyan
Write-Host ""

# Função para verificar porta
function Test-Port {
    param(
        [string]$IP,
        [int]$Port,
        [int]$Timeout = 500
    )
    
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $connect = $tcp.BeginConnect($IP, $Port, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne($Timeout, $false)
        
        if ($wait) {
            $tcp.EndConnect($connect)
            $tcp.Close()
            return $true
        }
        $tcp.Close()
        return $false
    } catch {
        return $false
    }
}

# Função para obter ID do AnyDesk LOCAL
function Get-LocalAnyDeskID {
    $paths = @(
        "$env:APPDATA\AnyDesk\service.conf",
        "$env:PROGRAMDATA\AnyDesk\service.conf",
        "C:\ProgramData\AnyDesk\service.conf",
        "$env:APPDATA\AnyDesk\user.conf"
    )
    
    foreach ($path in $paths) {
        if (Test-Path $path) {
            $content = Get-Content $path -ErrorAction SilentlyContinue
            foreach ($line in $content) {
                if ($line -match 'ad\.anynet\.id=(\d+)') {
                    return $matches[1]
                }
            }
        }
    }
    
    return $null
}

# 1. Verificar AnyDesk LOCAL
Write-Host "[LOCAL] Verificando AnyDesk local..." -ForegroundColor Yellow
Write-Host ""

$localID = Get-LocalAnyDeskID

if ($localID) {
    $formattedID = $localID -replace '(\d{1})(\d{3})(\d{3})(\d{3})', '$1 $2 $3 $4'
    Write-Host "OK AnyDesk ID Local: $formattedID" -ForegroundColor Green
    Write-Host "   (Formato sem espacos: $localID)" -ForegroundColor DarkGray
} else {
    Write-Host "X AnyDesk nao encontrado localmente" -ForegroundColor Red
}

Write-Host ""
Write-Host "================================================" -ForegroundColor DarkGray
Write-Host ""

# 2. Escanear rede especificada
Write-Host "[REDE] Escaneando rede: $RedeBase.0/24" -ForegroundColor Yellow
Write-Host "Range: $RedeBase.$InicioIP ate $RedeBase.$FimIP" -ForegroundColor Cyan
Write-Host "Verificando portas: 7070 (AnyDesk) e 3389 (RDP)" -ForegroundColor Cyan
Write-Host ""

$encontrados = @()

for ($i = $InicioIP; $i -le $FimIP; $i++) {
    $ip = "$RedeBase.$i"
    
    if ($i % 10 -eq 0) {
        Write-Host "Progresso: $i/$FimIP ..." -ForegroundColor DarkGray
    }
    
    $temAnyDesk = Test-Port -IP $ip -Port 7070
    $temRDP = Test-Port -IP $ip -Port 3389
    
    if ($temAnyDesk -or $temRDP) {
        $hostname = "Desconhecido"
        try {
            $hostname = [System.Net.Dns]::GetHostEntry($ip).HostName
        } catch {
            $hostname = "Nao resolvido"
        }
        
        $servicos = @()
        if ($temAnyDesk) { $servicos += "AnyDesk" }
        if ($temRDP) { $servicos += "RDP" }
        
        $encontrados += [PSCustomObject]@{
            IP = $ip
            Hostname = $hostname
            AnyDesk = if ($temAnyDesk) { "Sim" } else { "Nao" }
            RDP = if ($temRDP) { "Sim" } else { "Nao" }
            ComoConectar = if ($temRDP) { "mstsc /v:$ip" } else { "Precisa do ID do AnyDesk" }
        }
        
        Write-Host ""
        Write-Host "OK Dispositivo encontrado!" -ForegroundColor Green
        Write-Host "  IP: $ip" -ForegroundColor White
        Write-Host "  Hostname: $hostname" -ForegroundColor White
        Write-Host "  AnyDesk (porta 7070): $(if ($temAnyDesk) { 'SIM' } else { 'NAO' })" -ForegroundColor $(if ($temAnyDesk) { "Green" } else { "Red" })
        Write-Host "  RDP (porta 3389): $(if ($temRDP) { 'SIM' } else { 'NAO' })" -ForegroundColor $(if ($temRDP) { "Green" } else { "Red" })
        
        if ($temRDP) {
            Write-Host "  >> Para conectar via RDP: mstsc /v:$ip" -ForegroundColor Cyan
        }
        
        Write-Host ""
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor DarkGray
Write-Host ""

# 3. Resumo
Write-Host "=== RESUMO ===" -ForegroundColor Cyan
Write-Host ""

if ($encontrados.Count -eq 0) {
    Write-Host "Nenhum dispositivo com AnyDesk ou RDP encontrado." -ForegroundColor Yellow
} else {
    Write-Host "Total de dispositivos encontrados: $($encontrados.Count)" -ForegroundColor Green
    Write-Host ""
    
    $encontrados | Format-Table -AutoSize
    
    $outputFile = "dispositivos_encontrados_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    
    # Salvar com instruções de conexão
    "=== DISPOSITIVOS COM ANYDESK E/OU RDP ===" | Out-File -FilePath $outputFile -Encoding UTF8
    "Rede escaneada: $RedeBase.0/24 (Range: $InicioIP-$FimIP)" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    "" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    $encontrados | Format-Table -AutoSize | Out-File -FilePath $outputFile -Append -Encoding UTF8
    "" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    "=== COMO CONECTAR ===" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    "" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    
    foreach ($item in $encontrados) {
        "IP: $($item.IP) - $($item.Hostname)" | Out-File -FilePath $outputFile -Append -Encoding UTF8
        
        if ($item.RDP -eq "Sim") {
            "  RDP: mstsc /v:$($item.IP)" | Out-File -FilePath $outputFile -Append -Encoding UTF8
            "  Ou: Iniciar > Conexao de Area de Trabalho Remota > Digite: $($item.IP)" | Out-File -FilePath $outputFile -Append -Encoding UTF8
        }
        
        if ($item.AnyDesk -eq "Sim") {
            "  AnyDesk: Precisa do ID (use .\obter_id_anydesk.ps1 na maquina remota)" | Out-File -FilePath $outputFile -Append -Encoding UTF8
        }
        
        "" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    }
    
    Write-Host ""
    Write-Host "Resultados salvos em: $outputFile" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== INSTRUCOES ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "PARA CONECTAR VIA RDP:" -ForegroundColor Yellow
Write-Host "  1. Pressione Win + R" -ForegroundColor White
Write-Host "  2. Digite: mstsc /v:IP_DA_MAQUINA" -ForegroundColor White
Write-Host "  3. Ou use: Conexao de Area de Trabalho Remota" -ForegroundColor White
Write-Host ""
Write-Host "PARA CONECTAR VIA ANYDESK:" -ForegroundColor Yellow
Write-Host "  1. Voce precisa do ID do AnyDesk da maquina remota" -ForegroundColor White
Write-Host "  2. Acesse a maquina via RDP primeiro (se disponivel)" -ForegroundColor White
Write-Host "  3. Execute: .\obter_id_anydesk.ps1" -ForegroundColor White
Write-Host "  4. Use o ID no seu AnyDesk local" -ForegroundColor White
Write-Host ""
Write-Host "=== EXEMPLOS DE USO ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Escanear rede 192.168.15.0/24 completa:" -ForegroundColor Yellow
Write-Host "  .\descobrir_anydesk_e_rdp_rapido.ps1 -RedeBase '192.168.15'" -ForegroundColor White
Write-Host ""
Write-Host "Escanear apenas IPs 1 a 50:" -ForegroundColor Yellow
Write-Host "  .\descobrir_anydesk_e_rdp_rapido.ps1 -RedeBase '192.168.15' -InicioIP 1 -FimIP 50" -ForegroundColor White
Write-Host ""
Write-Host "Escanear outra rede:" -ForegroundColor Yellow
Write-Host "  .\descobrir_anydesk_e_rdp_rapido.ps1 -RedeBase '10.0.0'" -ForegroundColor White
Write-Host ""
