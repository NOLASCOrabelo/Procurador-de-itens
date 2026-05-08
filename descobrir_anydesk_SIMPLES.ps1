Write-Host "=== Descobridor de AnyDesk na Rede Local ===" -ForegroundColor Cyan
Write-Host ""

# Função para verificar se AnyDesk está rodando
function Test-AnyDeskPort {
    param([string]$IP)
    
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $connect = $tcp.BeginConnect($IP, 7070, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne(1000, $false)
        
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

# 1. Verificar AnyDesk local
Write-Host "[LOCAL] Verificando AnyDesk local..." -ForegroundColor Yellow
Write-Host ""

$localID = $null
$paths = @(
    "$env:APPDATA\AnyDesk\service.conf",
    "$env:PROGRAMDATA\AnyDesk\service.conf",
    "C:\ProgramData\AnyDesk\service.conf"
)

foreach ($path in $paths) {
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
    Write-Host "OK AnyDesk ID Local: $localID" -ForegroundColor Green
} else {
    Write-Host "X AnyDesk nao encontrado localmente" -ForegroundColor Red
}

Write-Host ""
Write-Host "================================================" -ForegroundColor DarkGray
Write-Host ""

# 2. Descobrir rede
Write-Host "[REDE] Descobrindo dispositivos na rede..." -ForegroundColor Yellow
Write-Host ""

$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*" 
} | Select-Object -First 1).IPAddress

if (-not $localIP) {
    Write-Host "Nao foi possivel determinar o IP local." -ForegroundColor Red
    exit
}

Write-Host "IP Local: $localIP" -ForegroundColor Cyan

$networkBase = $localIP.Substring(0, $localIP.LastIndexOf('.'))
Write-Host "Escaneando rede: $networkBase.0/24" -ForegroundColor Cyan
Write-Host ""

$scanAll = Read-Host "Escanear toda a rede (1-254)? (S/N)"

if ($scanAll -eq 'S' -or $scanAll -eq 's') {
    $startIP = 1
    $endIP = 254
} else {
    $startIP = [int](Read-Host "IP inicial (1-254)")
    $endIP = [int](Read-Host "IP final (1-254)")
}

Write-Host ""
Write-Host "Escaneando de $networkBase.$startIP ate $networkBase.$endIP ..." -ForegroundColor Yellow
Write-Host ""

$encontrados = @()

for ($i = $startIP; $i -le $endIP; $i++) {
    $ip = "$networkBase.$i"
    
    if ($i % 10 -eq 0) {
        Write-Host "Progresso: $i/$endIP ..." -ForegroundColor DarkGray
    }
    
    if (Test-AnyDeskPort -IP $ip) {
        $hostname = "Desconhecido"
        try {
            $hostname = [System.Net.Dns]::GetHostEntry($ip).HostName
        } catch {
            $hostname = "Nao resolvido"
        }
        
        $encontrados += [PSCustomObject]@{
            IP = $ip
            Hostname = $hostname
        }
        
        Write-Host ""
        Write-Host "OK AnyDesk encontrado!" -ForegroundColor Green
        Write-Host "  IP: $ip" -ForegroundColor White
        Write-Host "  Hostname: $hostname" -ForegroundColor White
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
    Write-Host "Nenhum AnyDesk encontrado na rede." -ForegroundColor Yellow
} else {
    Write-Host "Total de AnyDesks encontrados: $($encontrados.Count)" -ForegroundColor Green
    Write-Host ""
    
    $encontrados | Format-Table -AutoSize
    
    $outputFile = "anydesk_descobertos_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $encontrados | Out-File -FilePath $outputFile -Encoding UTF8
    Write-Host ""
    Write-Host "Resultados salvos em: $outputFile" -ForegroundColor Green
}

Write-Host ""
