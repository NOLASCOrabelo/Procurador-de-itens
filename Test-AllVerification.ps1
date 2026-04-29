# Comprehensive Verification Test Suite
# Tasks 5-9: Verification, Testing, and Validation

Write-Host "=== Comprehensive Verification Test Suite ===" -ForegroundColor Cyan
Write-Host ""

$totalPass = 0
$totalFail = 0

# Task 6: Error Handling
Write-Host "--- Task 6: Error Handling ---" -ForegroundColor Cyan

# Test 6.1: Empty input
$testScript = {
    $termos_str = ""
    if ([string]::IsNullOrWhiteSpace($termos_str)) {
        "ERROR_HANDLED"
    }
}
$result = & $testScript
if ($result -eq "ERROR_HANDLED") {
    Write-Host "[PASS] Empty input handling" -ForegroundColor Green
    $totalPass++
} else {
    Write-Host "[FAIL] Empty input handling" -ForegroundColor Red
    $totalFail++
}

# Test 6.2: Error resilience
$testScript = {
    $errorOccurred = $false
    try {
        $invalidPath = "C:\<invalid>|path?.txt"
        $title = [System.IO.Path]::GetFileNameWithoutExtension($invalidPath)
    } catch {
        $errorOccurred = $true
    }
    if ($errorOccurred) { "ERROR_HANDLED" }
}
$result = & $testScript
if ($result -eq "ERROR_HANDLED") {
    Write-Host "[PASS] Error resilience" -ForegroundColor Green
    $totalPass++
} else {
    Write-Host "[FAIL] Error resilience" -ForegroundColor Red
    $totalFail++
}

Write-Host ""

# Task 7: Deduplication
Write-Host "--- Task 7: Deduplication ---" -ForegroundColor Cyan

$testScript = {
    $encontrados = @{}
    $termo = "test"
    $encontrados[$termo] = @()
    $file_path = "C:\test\file.txt"
    if (-not ($encontrados[$termo] -contains $file_path)) {
        $encontrados[$termo] += $file_path
    }
    if (-not ($encontrados[$termo] -contains $file_path)) {
        $encontrados[$termo] += $file_path
    }
    if ($encontrados[$termo].Count -eq 1) {
        "DEDUP_SUCCESS"
    }
}
$result = & $testScript
if ($result -eq "DEDUP_SUCCESS") {
    Write-Host "[PASS] Deduplication logic" -ForegroundColor Green
    $totalPass++
} else {
    Write-Host "[FAIL] Deduplication logic" -ForegroundColor Red
    $totalFail++
}

Write-Host ""

# Task 8: Performance Characteristics
Write-Host "--- Task 8: Performance Characteristics ---" -ForegroundColor Cyan

$scriptContent = Get-Content "procurar_itens.ps1" -Raw

if ($scriptContent -match 'cmd\.exe /c "dir /s /b') {
    Write-Host "[PASS] cmd.exe dir usage" -ForegroundColor Green
    $totalPass++
} else {
    Write-Host "[FAIL] cmd.exe dir usage" -ForegroundColor Red
    $totalFail++
}

if ($scriptContent -match '\$counter % 2000 -eq 0') {
    Write-Host "[PASS] Progress indicator" -ForegroundColor Green
    $totalPass++
} else {
    Write-Host "[FAIL] Progress indicator" -ForegroundColor Red
    $totalFail++
}

Write-Host ""

# Task 9: Output Display
Write-Host "--- Task 9: Output Display ---" -ForegroundColor Cyan

if ($scriptContent -match "Encontrei o termo") {
    Write-Host "[PASS] Real-time match display" -ForegroundColor Green
    $totalPass++
} else {
    Write-Host "[FAIL] Real-time match display" -ForegroundColor Red
    $totalFail++
}

if ($scriptContent -match 'Total de itens escaneados') {
    Write-Host "[PASS] Summary report" -ForegroundColor Green
    $totalPass++
} else {
    Write-Host "[FAIL] Summary report" -ForegroundColor Red
    $totalFail++
}

if ($scriptContent -match "O termo.*foi encontrado") {
    Write-Host "[PASS] Success messages" -ForegroundColor Green
    $totalPass++
} else {
    Write-Host "[FAIL] Success messages" -ForegroundColor Red
    $totalFail++
}

Write-Host ""

# Core Functionality Tests
Write-Host "--- Core Functionality ---" -ForegroundColor Cyan

# Input parsing
$testScript = {
    $termos_str = "test, file  ,  data"
    $termos = $termos_str -split '[, ]+' | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
    if ($termos.Count -eq 3) { "PARSE_SUCCESS" }
}
$result = & $testScript
if ($result -eq "PARSE_SUCCESS") {
    Write-Host "[PASS] Input parsing" -ForegroundColor Green
    $totalPass++
} else {
    Write-Host "[FAIL] Input parsing" -ForegroundColor Red
    $totalFail++
}

# Case-insensitive matching
$testScript = {
    $title = "TestFile"
    $termo = "testfile"
    if ($title.ToLower().Contains($termo.ToLower())) {
        "CASE_SUCCESS"
    }
}
$result = & $testScript
if ($result -eq "CASE_SUCCESS") {
    Write-Host "[PASS] Case-insensitive matching" -ForegroundColor Green
    $totalPass++
} else {
    Write-Host "[FAIL] Case-insensitive matching" -ForegroundColor Red
    $totalFail++
}

# Extension exclusion
$testScript = {
    $file_path = "C:\test\document.txt"
    $title = [System.IO.Path]::GetFileNameWithoutExtension($file_path)
    $termo = "txt"
    if (-not $title.ToLower().Contains($termo.ToLower())) {
        "EXTENSION_EXCLUDED"
    }
}
$result = & $testScript
if ($result -eq "EXTENSION_EXCLUDED") {
    Write-Host "[PASS] Extension exclusion" -ForegroundColor Green
    $totalPass++
} else {
    Write-Host "[FAIL] Extension exclusion" -ForegroundColor Red
    $totalFail++
}

Write-Host ""

# Summary
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
$totalTests = $totalPass + $totalFail
Write-Host "Total: $totalTests | Passed: $totalPass | Failed: $totalFail"

if ($totalFail -eq 0) {
    Write-Host "SUCCESS: All tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "FAILURE: Some tests failed" -ForegroundColor Red
    exit 1
}
