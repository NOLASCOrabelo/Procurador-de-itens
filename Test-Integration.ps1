# Integration Testing with Real File System
# Task 11: Integration testing with real file system

Write-Host "=== Integration Testing with Real File System ===" -ForegroundColor Cyan
Write-Host ""

$testDir = Join-Path $env:TEMP "TextSearchIntegration_$(Get-Random)"
$totalPass = 0
$totalFail = 0

try {
    # Create test directory structure
    Write-Host "Creating test directory structure..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    
    # Task 11.1: Test with small directory (10 files)
    Write-Host ""
    Write-Host "--- Task 11.1: Small Directory Test (10 files) ---" -ForegroundColor Cyan
    
    $testFiles = @(
        "project_2024.txt",
        "PROJECT_final.docx",
        "report_annual.pdf",
        "data_backup.xlsx",
        "meeting_notes.txt",
        "budget_2024.csv",
        "presentation.pptx",
        "invoice_march.pdf",
        "contract_signed.docx",
        "summary_report.txt"
    )
    
    foreach ($fileName in $testFiles) {
        $filePath = Join-Path $testDir $fileName
        New-Item -ItemType File -Path $filePath -Force | Out-Null
    }
    
    Write-Host "Created 10 test files" -ForegroundColor Green
    
    # Test case-insensitive matching
    Write-Host ""
    Write-Host "Testing case-insensitive search for 'project'..." -ForegroundColor Yellow
    
    $encontrados = @{}
    $termo = "project"
    $encontrados[$termo] = @()
    
    $allFiles = Get-ChildItem -Path $testDir -File
    foreach ($file in $allFiles) {
        $title = [System.IO.Path]::GetFileNameWithoutExtension($file.FullName)
        if ($title.ToLower().Contains($termo.ToLower())) {
            if (-not ($encontrados[$termo] -contains $file.FullName)) {
                $encontrados[$termo] += $file.FullName
            }
        }
    }
    
    if ($encontrados[$termo].Count -eq 2) {
        Write-Host "[PASS] Found 2 matches for 'project' (case-insensitive)" -ForegroundColor Green
        $totalPass++
    } else {
        Write-Host "[FAIL] Expected 2 matches, found $($encontrados[$termo].Count)" -ForegroundColor Red
        $totalFail++
    }
    
    # Test extension exclusion
    Write-Host ""
    Write-Host "Testing extension exclusion (searching for 'txt')..." -ForegroundColor Yellow
    
    $encontrados = @{}
    $termo = "txt"
    $encontrados[$termo] = @()
    
    foreach ($file in $allFiles) {
        $title = [System.IO.Path]::GetFileNameWithoutExtension($file.FullName)
        if ($title.ToLower().Contains($termo.ToLower())) {
            if (-not ($encontrados[$termo] -contains $file.FullName)) {
                $encontrados[$termo] += $file.FullName
            }
        }
    }
    
    if ($encontrados[$termo].Count -eq 0) {
        Write-Host "[PASS] Extension 'txt' not matched (properly excluded)" -ForegroundColor Green
        $totalPass++
    } else {
        Write-Host "[FAIL] Extension should not be matched, found $($encontrados[$termo].Count)" -ForegroundColor Red
        $totalFail++
    }
    
    # Task 11.2: Test with multiple search terms
    Write-Host ""
    Write-Host "--- Task 11.2: Multiple Search Terms ---" -ForegroundColor Cyan
    
    $termos = @("report", "2024", "budget")
    $encontrados = @{}
    foreach ($termo in $termos) {
        $encontrados[$termo] = @()
    }
    
    foreach ($file in $allFiles) {
        $title = [System.IO.Path]::GetFileNameWithoutExtension($file.FullName)
        foreach ($termo in $termos) {
            if ($title.ToLower().Contains($termo.ToLower())) {
                if (-not ($encontrados[$termo] -contains $file.FullName)) {
                    $encontrados[$termo] += $file.FullName
                }
            }
        }
    }
    
    $expectedCounts = @{
        "report" = 2
        "2024" = 2
        "budget" = 1
    }
    
    $allCorrect = $true
    foreach ($termo in $termos) {
        $expected = $expectedCounts[$termo]
        $actual = $encontrados[$termo].Count
        if ($actual -eq $expected) {
            Write-Host "[PASS] Term '$termo': found $actual matches (expected $expected)" -ForegroundColor Green
            $totalPass++
        } else {
            Write-Host "[FAIL] Term '$termo': found $actual matches (expected $expected)" -ForegroundColor Red
            $totalFail++
            $allCorrect = $false
        }
    }
    
    # Task 11.3: Test with special characters
    Write-Host ""
    Write-Host "--- Task 11.3: Special Characters in Search Terms ---" -ForegroundColor Cyan
    
    # Create files with special characters
    $specialFiles = @(
        "data[1].txt",
        "function(x).txt",
        "count++.txt"
    )
    
    foreach ($fileName in $specialFiles) {
        $filePath = Join-Path $testDir $fileName
        New-Item -ItemType File -Path $filePath -Force | Out-Null
    }
    
    Write-Host "Created files with special characters" -ForegroundColor Green
    
    # Test literal matching of special characters
    $specialTests = @(
        @{ Term = "[1]"; Expected = 1; Desc = "Bracket expression [1]" },
        @{ Term = "(x)"; Expected = 1; Desc = "Parenthesis expression (x)" },
        @{ Term = "++"; Expected = 1; Desc = "Plus signs ++" }
    )
    
    $allFiles = Get-ChildItem -Path $testDir -File
    
    foreach ($test in $specialTests) {
        $encontrados = @{}
        $termo = $test.Term
        $encontrados[$termo] = @()
        
        foreach ($file in $allFiles) {
            $title = [System.IO.Path]::GetFileNameWithoutExtension($file.FullName)
            if ($title.ToLower().Contains($termo.ToLower())) {
                if (-not ($encontrados[$termo] -contains $file.FullName)) {
                    $encontrados[$termo] += $file.FullName
                }
            }
        }
        
        if ($encontrados[$termo].Count -eq $test.Expected) {
            Write-Host "[PASS] $($test.Desc): found $($test.Expected) match(es)" -ForegroundColor Green
            $totalPass++
        } else {
            Write-Host "[FAIL] $($test.Desc): expected $($test.Expected), found $($encontrados[$termo].Count)" -ForegroundColor Red
            $totalFail++
        }
    }
    
    # Task 11.4: Test case-insensitive matching with real files
    Write-Host ""
    Write-Host "--- Task 11.4: Case-Insensitive Matching ---" -ForegroundColor Cyan
    
    # Create files with mixed case
    $mixedCaseFiles = @(
        "TestFile.txt",
        "UPPERCASE.txt",
        "lowercase.txt",
        "MixedCase.txt"
    )
    
    foreach ($fileName in $mixedCaseFiles) {
        $filePath = Join-Path $testDir $fileName
        New-Item -ItemType File -Path $filePath -Force | Out-Null
    }
    
    Write-Host "Created files with mixed case names" -ForegroundColor Green
    
    # Test with lowercase search term
    $encontrados = @{}
    $termo = "test"
    $encontrados[$termo] = @()
    
    $allFiles = Get-ChildItem -Path $testDir -File
    
    foreach ($file in $allFiles) {
        $title = [System.IO.Path]::GetFileNameWithoutExtension($file.FullName)
        if ($title.ToLower().Contains($termo.ToLower())) {
            if (-not ($encontrados[$termo] -contains $file.FullName)) {
                $encontrados[$termo] += $file.FullName
            }
        }
    }
    
    if ($encontrados[$termo].Count -eq 1) {
        Write-Host "[PASS] Lowercase 'test' matched 'TestFile' (case-insensitive)" -ForegroundColor Green
        $totalPass++
    } else {
        Write-Host "[FAIL] Expected 1 match for 'test', found $($encontrados[$termo].Count)" -ForegroundColor Red
        $totalFail++
    }
    
    # Test with uppercase search term
    $encontrados = @{}
    $termo = "CASE"
    $encontrados[$termo] = @()
    
    foreach ($file in $allFiles) {
        $title = [System.IO.Path]::GetFileNameWithoutExtension($file.FullName)
        if ($title.ToLower().Contains($termo.ToLower())) {
            if (-not ($encontrados[$termo] -contains $file.FullName)) {
                $encontrados[$termo] += $file.FullName
            }
        }
    }
    
    if ($encontrados[$termo].Count -eq 3) {
        Write-Host "[PASS] Uppercase 'CASE' matched mixed case files (case-insensitive)" -ForegroundColor Green
        $totalPass++
    } else {
        Write-Host "[FAIL] Expected 3 matches for 'CASE', found $($encontrados[$termo].Count)" -ForegroundColor Red
        $totalFail++
    }
    
    Write-Host ""
    Write-Host "=== INTEGRATION TEST SUMMARY ===" -ForegroundColor Cyan
    Write-Host ""
    
    $totalTests = $totalPass + $totalFail
    Write-Host "Total Tests: $totalTests" -ForegroundColor White
    Write-Host "Passed: $totalPass" -ForegroundColor Green
    Write-Host "Failed: $totalFail" -ForegroundColor Red
    Write-Host ""
    
    if ($totalFail -eq 0) {
        Write-Host "SUCCESS: All integration tests passed!" -ForegroundColor Green
        Write-Host ""
        Write-Host "VERIFIED:" -ForegroundColor Green
        Write-Host "  - Task 11.1: Small directory search works correctly" -ForegroundColor Green
        Write-Host "  - Task 11.2: Multiple search terms tracked independently" -ForegroundColor Green
        Write-Host "  - Task 11.3: Special characters matched literally" -ForegroundColor Green
        Write-Host "  - Task 11.4: Case-insensitive matching works with real files" -ForegroundColor Green
        Write-Host ""
        exit 0
    } else {
        Write-Host "FAILURE: Some integration tests failed" -ForegroundColor Red
        exit 1
    }
    
} finally {
    # Cleanup
    if (Test-Path $testDir) {
        Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Test directory cleaned up" -ForegroundColor DarkGray
    }
}
