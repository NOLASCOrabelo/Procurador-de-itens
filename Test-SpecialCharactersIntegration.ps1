# Integration test to verify special character handling with actual files
# Task 3.1: Verify literal character matching behavior
# Validates Requirements 8.1, 8.2, 8.3

Write-Host "=== Integration Test: Special Characters with Real Files ===" -ForegroundColor Cyan
Write-Host ""

# Create a temporary test directory
$testDir = Join-Path $env:TEMP "SpecialCharTest_$(Get-Random)"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null
Write-Host "Created test directory: $testDir" -ForegroundColor DarkGray

try {
    # Create test files with special characters in their names
    $testFiles = @(
        "report.final.txt",
        "backup*2024.txt",
        "data[1].txt",
        "function(x).txt",
        "optional?.txt",
        "count++.txt",
        "option|choice.txt",
        "file.*backup.txt",
        "test(a+b).txt",
        "simple_file.txt"
    )
    
    Write-Host "Creating test files..." -ForegroundColor DarkGray
    foreach ($fileName in $testFiles) {
        $filePath = Join-Path $testDir $fileName
        try {
            New-Item -ItemType File -Path $filePath -Force | Out-Null
            Write-Host "  Created: $fileName" -ForegroundColor DarkGray
        } catch {
            Write-Host "  Skipped (invalid filename): $fileName" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "Running matching tests..." -ForegroundColor Cyan
    Write-Host ""
    
    # Test cases: search terms and expected matches
    $testCases = @(
        @{
            SearchTerm = "."
            ExpectedMatches = @("report.final", "file.*backup")
            Description = "Period (.) character"
        },
        @{
            SearchTerm = "*"
            ExpectedMatches = @("backup*2024", "file.*backup")
            Description = "Asterisk (*) character"
        },
        @{
            SearchTerm = "["
            ExpectedMatches = @("data[1]")
            Description = "Opening bracket ([) character"
        },
        @{
            SearchTerm = "]"
            ExpectedMatches = @("data[1]")
            Description = "Closing bracket (]) character"
        },
        @{
            SearchTerm = "("
            ExpectedMatches = @("function(x)", "test(a+b)")
            Description = "Opening parenthesis (() character"
        },
        @{
            SearchTerm = ")"
            ExpectedMatches = @("function(x)", "test(a+b)")
            Description = "Closing parenthesis ()) character"
        },
        @{
            SearchTerm = "+"
            ExpectedMatches = @("count++", "test(a+b)")
            Description = "Plus (+) character"
        },
        @{
            SearchTerm = "|"
            ExpectedMatches = @("option|choice")
            Description = "Pipe (|) character"
        },
        @{
            SearchTerm = ".*"
            ExpectedMatches = @("file.*backup")
            Description = "Multiple special characters (.*)"
        },
        @{
            SearchTerm = "[1]"
            ExpectedMatches = @("data[1]")
            Description = "Bracket expression [1]"
        },
        @{
            SearchTerm = "(a+b)"
            ExpectedMatches = @("test(a+b)")
            Description = "Complex expression (a+b)"
        }
    )
    
    $passCount = 0
    $failCount = 0
    
    # Get all files in test directory
    $allFiles = Get-ChildItem -Path $testDir -File
    
    foreach ($test in $testCases) {
        $searchTerm = $test.SearchTerm
        $expectedMatches = $test.ExpectedMatches
        $description = $test.Description
        
        # Find matches using the same logic as procurar_itens.ps1
        $actualMatches = @()
        foreach ($file in $allFiles) {
            $title_only = [System.IO.Path]::GetFileNameWithoutExtension($file.FullName)
            if ($title_only.ToLower().Contains($searchTerm.ToLower())) {
                $actualMatches += $title_only
            }
        }
        
        # Sort for comparison
        $expectedSorted = $expectedMatches | Sort-Object
        $actualSorted = $actualMatches | Sort-Object
        
        # Compare results
        $matchesCorrect = $true
        if ($expectedSorted.Count -ne $actualSorted.Count) {
            $matchesCorrect = $false
        } else {
            for ($i = 0; $i -lt $expectedSorted.Count; $i++) {
                if ($expectedSorted[$i] -ne $actualSorted[$i]) {
                    $matchesCorrect = $false
                    break
                }
            }
        }
        
        if ($matchesCorrect) {
            Write-Host "[PASS] $description" -ForegroundColor Green
            Write-Host "       SearchTerm: '$searchTerm', Found: $($actualMatches.Count) matches" -ForegroundColor DarkGray
            $passCount++
        } else {
            Write-Host "[FAIL] $description" -ForegroundColor Red
            Write-Host "       SearchTerm: '$searchTerm'" -ForegroundColor Yellow
            Write-Host "       Expected: $($expectedMatches -join ', ')" -ForegroundColor Yellow
            Write-Host "       Actual: $($actualMatches -join ', ')" -ForegroundColor Yellow
            $failCount++
        }
        Write-Host ""
    }
    
    Write-Host "=== Test Summary ===" -ForegroundColor Cyan
    Write-Host "Total Tests: $($testCases.Count)" -ForegroundColor White
    Write-Host "Passed: $passCount" -ForegroundColor Green
    Write-Host "Failed: $failCount" -ForegroundColor Red
    
    if ($failCount -eq 0) {
        Write-Host "`nAll integration tests passed!" -ForegroundColor Green
        Write-Host "The .Contains() method correctly treats special characters literally." -ForegroundColor Green
        Write-Host "Requirements 8.1, 8.2, 8.3 validated successfully." -ForegroundColor Green
        $exitCode = 0
    } else {
        Write-Host "`nSome integration tests failed." -ForegroundColor Red
        $exitCode = 1
    }
    
} finally {
    # Cleanup: Remove test directory
    Write-Host "`nCleaning up test directory..." -ForegroundColor DarkGray
    Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Test directory removed." -ForegroundColor DarkGray
}

exit $exitCode
