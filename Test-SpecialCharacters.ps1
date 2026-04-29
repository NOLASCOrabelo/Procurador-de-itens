# Test script to verify that .Contains() treats special characters literally
# Task 3.1: Verify literal character matching behavior
# Validates Requirements 8.1, 8.2, 8.3

Write-Host "=== Testing .Contains() Literal Character Matching ===" -ForegroundColor Cyan
Write-Host ""

# Test data: file titles and search terms with special characters
$testCases = @(
    @{
        Title = "report.final"
        SearchTerm = "."
        ShouldMatch = $true
        Description = "Period (.) character"
    },
    @{
        Title = "backup*2024"
        SearchTerm = "*"
        ShouldMatch = $true
        Description = "Asterisk (*) character"
    },
    @{
        Title = "data[1]"
        SearchTerm = "["
        ShouldMatch = $true
        Description = "Opening bracket ([) character"
    },
    @{
        Title = "data[1]"
        SearchTerm = "]"
        ShouldMatch = $true
        Description = "Closing bracket (]) character"
    },
    @{
        Title = "function(x)"
        SearchTerm = "("
        ShouldMatch = $true
        Description = "Opening parenthesis (() character"
    },
    @{
        Title = "function(x)"
        SearchTerm = ")"
        ShouldMatch = $true
        Description = "Closing parenthesis ()) character"
    },
    @{
        Title = "optional?"
        SearchTerm = "?"
        ShouldMatch = $true
        Description = "Question mark (?) character"
    },
    @{
        Title = "count++"
        SearchTerm = "+"
        ShouldMatch = $true
        Description = "Plus (+) character"
    },
    @{
        Title = "option|choice"
        SearchTerm = "|"
        ShouldMatch = $true
        Description = "Pipe (|) character"
    },
    @{
        Title = "simple_file"
        SearchTerm = "."
        ShouldMatch = $false
        Description = "Period (.) should NOT match when not present"
    },
    @{
        Title = "simple_file"
        SearchTerm = "*"
        ShouldMatch = $false
        Description = "Asterisk (*) should NOT match when not present"
    },
    @{
        Title = "file.*backup"
        SearchTerm = ".*"
        ShouldMatch = $true
        Description = "Multiple special characters (.*) should match literally"
    },
    @{
        Title = "data[1]"
        SearchTerm = "[1]"
        ShouldMatch = $true
        Description = "Bracket expression [1] should match literally"
    },
    @{
        Title = "test(a+b)"
        SearchTerm = "(a+b)"
        ShouldMatch = $true
        Description = "Complex expression (a+b) should match literally"
    }
)

$passCount = 0
$failCount = 0

foreach ($test in $testCases) {
    $title = $test.Title
    $searchTerm = $test.SearchTerm
    $shouldMatch = $test.ShouldMatch
    $description = $test.Description
    
    # Simulate the matching logic from procurar_itens.ps1
    $actualMatch = $title.ToLower().Contains($searchTerm.ToLower())
    
    $testPassed = ($actualMatch -eq $shouldMatch)
    
    if ($testPassed) {
        Write-Host "[PASS] $description" -ForegroundColor Green
        Write-Host "       Title: '$title', SearchTerm: '$searchTerm', Expected: $shouldMatch, Actual: $actualMatch" -ForegroundColor DarkGray
        $passCount++
    } else {
        Write-Host "[FAIL] $description" -ForegroundColor Red
        Write-Host "       Title: '$title', SearchTerm: '$searchTerm', Expected: $shouldMatch, Actual: $actualMatch" -ForegroundColor Yellow
        $failCount++
    }
    Write-Host ""
}

Write-Host "=== Test Summary ===" -ForegroundColor Cyan
Write-Host "Total Tests: $($testCases.Count)" -ForegroundColor White
Write-Host "Passed: $passCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor Red

if ($failCount -eq 0) {
    Write-Host "`nAll tests passed! .Contains() treats special characters literally." -ForegroundColor Green
    Write-Host "Requirements 8.1, 8.2, 8.3 validated successfully." -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nSome tests failed. .Contains() may not be treating characters literally." -ForegroundColor Red
    exit 1
}
