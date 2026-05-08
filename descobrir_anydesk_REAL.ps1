Write-Host "=== Descobridor REAL de IDs AnyDesk na Rede ===" -ForegroundColor Cyan
Write-Host ""

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

# Função para obter ID do AnyDesk REMOTO via WMI/PowerShell Remoting
function Get-RemoteAnyDeskID {
    param(
        [string]$ComputerName,
        [string]$Username,
        [string]$Password
    )
    
    try {
        if ($Username -and $Password) {
            $secPass = ConvertTo-SecureString $Password -AsPlainText -Force
            $cred = New-Object System.Management.Automation.PSCredential($Username, $secPass)
            
            $id = Invoke-Command -ComputerName $ComputerName -Credential $cred -ScriptBlock {
                $paths = @(
                    "$env:APPDATA\AnyDesk\service.conf",
                    "$env:PROGRAMDATA\AnyDesk\service.conf",
                    "C:\ProgramData\AnyDesk\service.conf"
                )
                
                foreach ($path in $paths) {
                    if (Test-Path $path) {
                        $content = Get-Content $path
                        foreach ($line in $content) {
                            if ($line -match 'ad\.anynet\.id=(\d+)') {
                                return $matches[1]
                            }
                        }
                    }
                }
                return $null
            } -ErrorAction Stop
            
            return $id
        }
    } catch {
        return $null
    }
    
    return $null
}

# Função para verificar se porta 7070 está aberta
function Test-AnyDeskPort {
    param([string]$IP)
    
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $connect = $tcp.BeginConnect($IP, 7070, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne(500, $false)
        
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

# 1. Verificar AnyDesk LOCAL
Write-Host "[LOCAL] Verificando AnyDesk local..." -ForegroundColor Yellow
Write-Host ""

$localID = Get-LocalAnyDeskID

if ($localID) {
    # Formatar ID com espaços (formato AnyDesk)
    $formattedID = $localID -replace '(\d{1})(\d{3})(\d{3})(\d{3})', '$1 $2 $3 $4'
    Write-Host "OK AnyDesk ID Local: $formattedID" -ForegroundColor Green
    Write-Host "   (Formato sem espacos: $localID)" -ForegroundColor DarkGray
} else {
    Write-Host "X AnyDesk nao encontrado localmente" -ForegroundColor Red
}

Write-Host ""
Write-Host "================================================" -ForegroundColor DarkGray
Write-Host ""

# 2. Descobrir rede
Write-Host "[REDE] Descobrindo AnyDesks na rede..." -ForegroundColor Yellow
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
Write-Host "IMPORTANTE: Para obter IDs remotos, voce precisa:" -ForegroundColor Yellow
Write-Host "  1. Credenciais de administrador das maquinas remotas" -ForegroundColor Yellow
Write-Host "  2. PowerShell Remoting habilitado (Enable-PSRemoting)" -ForegroundColor Yellow
Write-Host "  3. Ou acesso fisico/RDP a cada maquina" -ForegroundColor Yellow
Write-Host ""

$tentarRemoto = Read-Host "Tentar obter IDs remotos via PowerShell Remoting? (S/N)"
$username = $null
$password = $null

if ($tentarRemoto -eq 'S' -or $tentarRemoto -eq 's') {
    $username = Read-Host "Usuario administrador (ex: DOMINIO\admin ou admin)"
    $password = Read-Host "Senha" -AsSecureString
    $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
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
        
        $anyDeskID = "Nao acessivel"
        
        # Tentar obter ID remoto
        if ($username -and $password) {
            Write-Host "  Tentando obter ID de $ip ..." -ForegroundColor DarkGray
            $remoteID = Get-RemoteAnyDeskID -ComputerName $ip -Username $username -Password $password
            if ($remoteID) {
                $anyDeskID = $remoteID -replace '(\d{1})(\d{3})(\d{3})(\d{3})', '$1 $2 $3 $4'
            }
        }
        
        $encontrados += [PSCustomObject]@{
            IP = $ip
            Hostname = $hostname
            AnyDeskID = $anyDeskID
        }
        
        Write-Host ""
        Write-Host "OK AnyDesk encontrado!" -ForegroundColor Green
        Write-Host "  IP: $ip" -ForegroundColor White
        Write-Host "  Hostname: $hostname" -ForegroundColor White
        Write-Host "  AnyDesk ID: $anyDeskID" -ForegroundColor $(if ($anyDeskID -ne "Nao acessivel") { "Green" } else { "Yellow" })
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
    
    $outputFile = "anydesk_ids_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $encontrados | Out-File -FilePath $outputFile -Encoding UTF8
    Write-Host ""
    Write-Host "Resultados salvos em: $outputFile" -ForegroundColor Green
}

Write-Host ""
Write-Host "NOTA: Se os IDs aparecem como 'Nao acessivel':" -ForegroundColor Yellow
Write-Host "  - Voce precisa acessar cada maquina individualmente (RDP/fisicamente)" -ForegroundColor Yellow
Write-Host "  - Ou habilitar PowerShell Remoting em cada maquina" -ForegroundColor Yellow
Write-Host "  - O ID fica em: %APPDATA%\AnyDesk\service.conf" -ForegroundColor Yellow
Write-Host ""
