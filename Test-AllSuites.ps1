# Run All Test Suites
# Comprehensive test execution for Tasks 5-12

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  COMPREHENSIVE TEST SUITE EXECUTION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allPassed = $true

# Test Suite 1: Comprehensive Verification (Tasks 6-9)
Write-Host "[1/4] Running Comprehensive Verification Tests..." -ForegroundColor Yellow
$result = & .\Test-AllVerification.ps1
if ($LASTEXITCODE -ne 0) {
    $allPassed = $false
    Write-Host "FAILED: Comprehensive Verification Tests" -ForegroundColor Red
} else {
    Write-Host "PASSED: Comprehensive Verification Tests" -ForegroundColor Green
}
Write-Host ""

# Test Suite 2: Special Characters (Task 3)
Write-Host "[2/4] Running Special Characters Tests..." -ForegroundColor Yellow
$result = & .\Test-SpecialCharacters-Final.ps1
if ($LASTEXITCODE -ne 0) {
    $allPassed = $false
    Write-Host "FAILED: Special Characters Tests" -ForegroundColor Red
} else {
    Write-Host "PASSED: Special Characters Tests" -ForegroundColor Green
}
Write-Host ""

# Test Suite 3: Integration Tests (Task 11)
Write-Host "[3/4] Running Integration Tests..." -ForegroundColor Yellow
$result = & .\Test-Integration.ps1
if ($LASTEXITCODE -ne 0) {
    $allPassed = $false
    Write-Host "FAILED: Integration Tests" -ForegroundColor Red
} else {
    Write-Host "PASSED: Integration Tests" -ForegroundColor Green
}
Write-Host ""

# Test Suite 4: Final Validation (Task 12)
Write-Host "[4/4] Running Final Validation Tests..." -ForegroundColor Yellow
$result = & .\Test-FinalValidation.ps1
if ($LASTEXITCODE -ne 0) {
    $allPassed = $false
    Write-Host "FAILED: Final Validation Tests" -ForegroundColor Red
} else {
    Write-Host "PASSED: Final Validation Tests" -ForegroundColor Green
}
Write-Host ""

# Final Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FINAL TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($allPassed) {
    Write-Host "SUCCESS: ALL TEST SUITES PASSED!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Test Coverage:" -ForegroundColor White
    Write-Host "  ✓ Task 5: Checkpoint - All tests pass" -ForegroundColor Green
    Write-Host "  ✓ Task 6: Error handling and edge cases" -ForegroundColor Green
    Write-Host "  ✓ Task 7: Result management and deduplication" -ForegroundColor Green
    Write-Host "  ✓ Task 8: Performance characteristics maintained" -ForegroundColor Green
    Write-Host "  ✓ Task 9: Output display completeness" -ForegroundColor Green
    Write-Host "  ✓ Task 10: Final checkpoint - All tests pass" -ForegroundColor Green
    Write-Host "  ✓ Task 11: Integration testing with real file system" -ForegroundColor Green
    Write-Host "  ✓ Task 12: Final validation and cleanup" -ForegroundColor Green
    Write-Host ""
    Write-Host "The text search capability implementation is COMPLETE and VALIDATED." -ForegroundColor Green
    Write-Host ""
    exit 0
} else {
    Write-Host "FAILURE: Some test suites failed" -ForegroundColor Red
    Write-Host "Please review the output above for details." -ForegroundColor Red
    Write-Host ""
    exit 1
}
