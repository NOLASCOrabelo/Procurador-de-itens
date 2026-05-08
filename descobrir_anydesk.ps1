Write-Host "=== Descobridor de AnyDesk na Rede Local ===" -ForegroundColor Cyan
Write-Host ""

# Função para obter ID do AnyDesk de uma máquina remota
function Get-AnyDeskID {
    param(
        [string]$ComputerName
    )
    
    try {
        # Tentar acessar o registro remoto (requer permissões administrativas)
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $ComputerName)
        $regKey = $reg.OpenSubKey("SOFTWARE\WOW6432Node\AnyDesk")
        
        if ($regKey) {
            $adId = $regKey.GetValue("ad.anynet.id")
            $regKey.Close()
            $reg.Close()
            return $adId
        }
        
        $reg.Close()
    } catch {
        # Silenciosamente falhar se não conseguir acessar
    }
    
    return $null
}

# Função para verificar se AnyDesk está rodando
function Test-AnyDeskRunning {
    param(
        [string]$IPAddress
    )
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connect = $tcpClient.BeginConnect($IPAddress, 7070, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne(1000, $false)
        
        if ($wait) {
            $tcpClient.EndConnect($connect)
            $tcpClient.Close()
            return $true
        } else {
            $tcpClient.Close()
            return $false
        }
    } catch {
        return $false
    }
}

# 1. Obter ID local
Write-Host "[LOCAL] Verificando AnyDesk local..." -ForegroundColor Yellow
Write-Host ""

$localID = $null
$anyDeskPaths = @(
    "$env:APPDATA\AnyDesk\service.conf",
    "$env:PROGRAMDATA\AnyDesk\service.conf",
    "C:\Program Files (x86)\AnyDesk\service.conf",
    "C:\ProgramData\AnyDesk\service.conf"
)

foreach ($path in $anyDeskPaths) {
    if (Test-Path $path) {
        $content = Get-Content $path -ErrorAction SilentlyContinue
        foreach ($line in $content) {
            if ($line -match 'ad\.anynet\.id=(\d+)') {
                $localID = $matches[1]
                break
            }
        }
        if ($localID) { break }
    }
}

if ($localID) {
    Write-Host "✓ AnyDesk ID Local: " -NoNewline -ForegroundColor Green
    Write-Host "$localID" -ForegroundColor White
} else {
    Write-Host "✗ AnyDesk não encontrado localmente" -ForegroundColor Red
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

# 2. Descobrir rede local
Write-Host "[REDE] Descobrindo dispositivos na rede local..." -ForegroundColor Yellow
Write-Host ""

# Obter IP local e calcular range da rede
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*" } | Select-Object -First 1).IPAddress

if (-not $localIP) {
    Write-Host "Não foi possível determinar o IP local." -ForegroundColor Red
    exit
}

Write-Host "IP Local: $localIP" -ForegroundColor Cyan

# Extrair os 3 primeiros octetos
$networkBase = $localIP.Substring(0, $localIP.LastIndexOf('.'))
Write-Host "Escaneando rede: $networkBase.0/24" -ForegroundColor Cyan
Write-Host ""

# Perguntar se quer escanear toda a rede
$scanAll = Read-Host "Deseja escanear toda a rede (1-254)? Isso pode levar alguns minutos. (S/N)"

if ($scanAll -eq 'S' -or $scanAll -eq 's') {
    $startIP = 1
    $endIP = 254
} else {
    $startIP = Read-Host "IP inicial (1-254)"
    $endIP = Read-Host "IP final (1-254)"
}

Write-Host ""
Write-Host "Escaneando IPs de $networkBase.$startIP até $networkBase.$endIP ..." -ForegroundColor Yellow
Write-Host "Procurando por AnyDesk (porta 7070)..." -ForegroundColor Yellow
Write-Host ""

$encontrados = @()
$contador = 0

for ($i = $startIP; $i -le $endIP; $i++) {
    $ip = "$networkBase.$i"
    $contador++
    
    # Mostrar progresso
    if ($contador % 10 -eq 0) {
        Write-Host "Progresso: $contador/$($endIP - $startIP + 1) IPs escaneados..." -ForegroundColor DarkGray
    }
    
    # Verificar se AnyDesk está rodando
    if (Test-AnyDeskRunning -IPAddress $ip) {
        # Tentar resolver hostname
        $hostname = "Desconhecido"
        try {
            $hostname = [System.Net.Dns]::GetHostEntry($ip).HostName
        } catch {
            $hostname = "Não resolvido"
        }
        
        # Tentar obter ID do AnyDesk
        $adID = Get-AnyDeskID -ComputerName $ip
        
        $encontrados += [PSCustomObject]@{
            IP = $ip
            Hostname = $hostname
            AnyDeskID = if ($adID) { $adID } else { "Não acessível" }
        }
        
        Write-Host ""
        Write-Host "✓ AnyDesk encontrado!" -ForegroundColor Green
        Write-Host "  IP: $ip" -ForegroundColor White
        Write-Host "  Hostname: $hostname" -ForegroundColor White
        Write-Host "  AnyDesk ID: $(if ($adID) { $adID } else { 'Não acessível (requer permissões admin)' })" -ForegroundColor White
        Write-Host ""
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

# 3. Resumo final
Write-Host "=== RESUMO ===" -ForegroundColor Cyan
Write-Host ""

if ($encontrados.Count -eq 0) {
    Write-Host "Nenhum AnyDesk encontrado na rede." -ForegroundColor Yellow
} else {
    Write-Host "Total de AnyDesks encontrados: $($encontrados.Count)" -ForegroundColor Green
    Write-Host ""
    
    $encontrados | Format-Table -AutoSize
    
    # Salvar em arquivo
    $outputFile = "anydesk_descobertos_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $encontrados | Out-File -FilePath $outputFile -Encoding UTF8
    Write-Host ""
    Write-Host "Resultados salvos em: $outputFile" -ForegroundColor Green
}

Write-Host ""
Write-Host "NOTA: Para obter os IDs remotos, é necessário:" -ForegroundColor Yellow
Write-Host "  1. Permissões administrativas na máquina remota" -ForegroundColor Yellow
Write-Host "  2. Compartilhamento de registro habilitado" -ForegroundColor Yellow
Write-Host "  3. Firewall permitindo acesso remoto ao registro" -ForegroundColor Yellow
Write-Host ""
