# Implementation Plan: Text Search Capability

## Overview

This implementation plan converts the `procurar_itens.ps1` PowerShell script from number-only search to arbitrary text search. The approach involves modifying input validation, updating matching logic to be case-insensitive, and updating all user-facing messages. The core performance optimization (using `cmd.exe dir`) will be preserved.

## Tasks

- [ ] 1. Update input parsing to accept arbitrary text
  - [ ] 1.1 Remove numeric-only validation logic
    - Remove the regex filter `Where-Object { $_ -match '^\d+$' }` from input parsing
    - Remove the error message "Nenhum número válido foi identificado na sua entrada"
    - _Requirements: 2.1, 2.2, 2.3_
  
  - [ ] 1.2 Add whitespace trimming for each parsed term
    - Add `.Trim()` to each term after splitting to remove leading/trailing spaces
    - Ensure empty strings are filtered out after trimming
    - _Requirements: 1.1, 1.3_
  
  - [ ] 1.3 Rename variables from numeric context to text context
    - Rename `$numeros_str` to `$termos_str`
    - Rename `$numeros` to `$termos`
    - Rename `$num` to `$termo` in loop variables
    - _Requirements: 7.3_
  
  - [ ]* 1.4 Write property test for input parsing
    - **Property 2: Multi-term parsing correctness**
    - **Validates: Requirements 1.3**
    - Generate random lists of terms with comma/space separators
    - Verify correct parsing, deduplication, and trimming
  
  - [ ]* 1.5 Write unit tests for input validation edge cases
    - Test empty input rejection
    - Test whitespace-only input rejection
    - Test single term parsing
    - Test multiple terms with mixed separators
    - _Requirements: 1.4_

- [ ] 2. Implement case-insensitive text matching
  - [ ] 2.1 Update matching logic to use case-insensitive comparison
    - Replace `$title_only.Contains($termo)` with `$title_only.ToLower().Contains($termo.ToLower())`
    - Ensure matching continues to use `GetFileNameWithoutExtension` for title extraction
    - _Requirements: 3.1, 3.2, 3.3_
  
  - [ ]* 2.2 Write property test for case-insensitive matching
    - **Property 3: Case-insensitive substring matching**
    - **Validates: Requirements 3.1, 3.2**
    - Generate random term/title pairs with various case combinations
    - Verify matches are found regardless of case
  
  - [ ]* 2.3 Write property test for extension exclusion
    - **Property 4: Extension exclusion from matching**
    - **Validates: Requirements 3.3**
    - Generate file paths with various extensions
    - Verify matching only considers filename without extension
  
  - [ ]* 2.4 Write unit tests for matching logic
    - Test exact match (term equals title)
    - Test partial match (term is substring of title)
    - Test no match (term not in title)
    - Test case variations (lowercase, uppercase, mixed)
    - _Requirements: 3.1, 3.2_

- [ ] 3. Handle special characters safely
  - [ ] 3.1 Verify literal character matching behavior
    - Confirm that `.Contains()` method treats all characters literally (not as regex)
    - Test with common special characters: `.`, `*`, `[`, `]`, `(`, `)`, `?`, `+`, `|`
    - _Requirements: 8.1, 8.2, 8.3_
  
  - [ ]* 3.2 Write property test for special character handling
    - **Property 11: Literal special character matching**
    - **Validates: Requirements 8.1, 8.2**
    - Generate terms with regex special characters
    - Verify literal matching (not pattern matching)
  
  - [ ]* 3.3 Write property test for invalid path characters
    - **Property 12: Invalid path character tolerance**
    - **Validates: Requirements 8.4**
    - Generate terms with invalid path characters (`<`, `>`, `|`, `:`, `"`)
    - Verify no errors during processing
  
  - [ ]* 3.4 Write unit tests for special character examples
    - Test literal matching of `.`, `*`, `[`, `]`
    - Test terms with multiple special characters
    - _Requirements: 8.1, 8.2_

- [ ] 4. Update all user-facing messages
  - [ ] 4.1 Update script title and header messages
    - Change title from "Procurador de Itens por Número no Título" to "Procurador de Itens por Texto no Título"
    - Update input prompt from "Digite os números que deseja procurar" to "Digite os termos que deseja procurar"
    - Update info message to reference "termos" instead of "números"
    - _Requirements: 7.1, 7.2, 7.3_
  
  - [ ] 4.2 Update real-time match display messages
    - Change success message from "Encontrei o número '$num'" to "Encontrei o termo '$termo'"
    - Maintain green color formatting for success messages
    - _Requirements: 5.1, 5.2, 5.3, 7.3_
  
  - [ ] 4.3 Update summary report messages
    - Change summary success from "O número '$num' foi encontrado" to "O termo '$termo' foi encontrado"
    - Change summary failure from "O número '$num' NÃO foi achado" to "O termo '$termo' NÃO foi achado"
    - Maintain color scheme (green for success, red for not found)
    - _Requirements: 6.2, 6.3, 6.4, 7.3, 7.4_
  
  - [ ]* 4.4 Write unit tests for message formatting
    - Verify title message format
    - Verify input prompt format
    - Verify real-time match message format
    - Verify summary success/failure message formats
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [ ] 5. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Verify error handling and edge cases
  - [ ] 6.1 Confirm error handling for empty input
    - Verify error message displays when input is empty or whitespace-only
    - Verify script exits gracefully with appropriate error code
    - _Requirements: 1.4_
  
  - [ ] 6.2 Confirm error handling during file system traversal
    - Verify try-catch block continues to handle access denied errors
    - Verify try-catch block continues to handle corrupted path errors
    - Verify script continues processing after individual errors
    - _Requirements: 4.3_
  
  - [ ]* 6.3 Write property test for error resilience
    - **Property 6: Error resilience during traversal**
    - **Validates: Requirements 4.3**
    - Simulate various errors (access denied, corrupted paths)
    - Verify script continues processing
  
  - [ ]* 6.4 Write unit tests for error handling
    - Test access denied error handling (mocked)
    - Test corrupted path error handling (mocked)
    - Test `GetFileNameWithoutExtension` exception handling (mocked)
    - _Requirements: 4.3_

- [ ] 7. Verify result management and deduplication
  - [ ] 7.1 Confirm unique match recording logic
    - Verify that duplicate paths are not added to results for the same term
    - Verify the check: `if (-not ($encontrados[$termo] -contains $file_path))`
    - _Requirements: 3.5, 5.4_
  
  - [ ]* 7.2 Write property test for unique match recording
    - **Property 5: Unique match recording**
    - **Validates: Requirements 3.5, 5.4**
    - Simulate multiple matches of same path
    - Verify each path recorded exactly once per term
  
  - [ ]* 7.3 Write unit tests for result management
    - Test single match recording
    - Test multiple matches for one term
    - Test multiple terms matching same file
    - _Requirements: 3.4, 3.5_

- [ ] 8. Verify performance characteristics are maintained
  - [ ] 8.1 Confirm `cmd.exe dir` usage is unchanged
    - Verify the command `cmd.exe /c "dir /s /b \"$source_path*\" 2>nul"` is still used
    - Verify no changes to file system traversal logic
    - _Requirements: 4.1_
  
  - [ ] 8.2 Confirm progress indicator functionality
    - Verify progress message displays every 2000 items: `if ($counter % 2000 -eq 0)`
    - Verify counter increments correctly for each item processed
    - _Requirements: 4.2_
  
  - [ ]* 8.3 Write property test for mixed item type processing
    - **Property 7: Mixed item type processing**
    - **Validates: Requirements 4.4**
    - Create test directories with files and folders
    - Verify both types are processed
  
  - [ ]* 8.4 Write unit tests for progress indicator
    - Test progress indicator at 2000 items
    - Test progress indicator at 4000 items
    - Test counter increment logic
    - _Requirements: 4.2_

- [ ] 9. Verify output display completeness
  - [ ] 9.1 Confirm real-time match display
    - Verify matches are displayed immediately when found
    - Verify both term and full path are shown
    - _Requirements: 5.1, 5.2_
  
  - [ ] 9.2 Confirm summary report completeness
    - Verify summary displays total items scanned
    - Verify summary includes entry for each search term
    - Verify summary shows correct match counts
    - _Requirements: 6.1, 6.2_
  
  - [ ]* 9.3 Write property test for real-time display
    - **Property 8: Real-time match display**
    - **Validates: Requirements 5.1, 5.2**
    - Generate matches during simulated scan
    - Verify immediate console output for each match
  
  - [ ]* 9.4 Write property test for summary completeness
    - **Property 9: Summary completeness**
    - **Validates: Requirements 6.2**
    - Generate various search term sets
    - Verify summary entry for each term
  
  - [ ]* 9.5 Write property test for conditional summary feedback
    - **Property 10: Conditional summary feedback**
    - **Validates: Requirements 6.3, 6.4**
    - Generate scenarios with and without matches
    - Verify appropriate success/failure messages

- [ ] 10. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 11. Integration testing with real file system
  - [ ] 11.1 Test with small directory (10 files)
    - Create test directory with known files containing specific text in titles
    - Run script with text search terms
    - Verify all expected matches are found
    - Verify no false positives
    - _Requirements: 3.1, 3.2, 3.3, 3.4_
  
  - [ ] 11.2 Test with multiple search terms
    - Run script with multiple terms (some matching, some not)
    - Verify each term's results are tracked separately
    - Verify summary shows correct counts for each term
    - _Requirements: 1.3, 6.2, 6.3, 6.4_
  
  - [ ] 11.3 Test with special characters in search terms
    - Run script with terms containing `.`, `*`, `[`, `]`, `(`, `)`
    - Verify literal matching behavior
    - Verify no regex interpretation errors
    - _Requirements: 8.1, 8.2, 8.3_
  
  - [ ] 11.4 Test case-insensitive matching with real files
    - Create files with mixed case titles
    - Run script with lowercase search terms
    - Verify matches are found regardless of case
    - _Requirements: 3.1, 3.2_
  
  - [ ]* 11.5 Test with large directory (performance validation)
    - Run script on directory with 10,000+ files
    - Verify performance is comparable to original number-only search
    - Verify progress indicators appear at expected intervals
    - _Requirements: 4.1, 4.2_

- [ ] 12. Final validation and cleanup
  - [ ] 12.1 Review all code changes for consistency
    - Verify all variable names updated from numeric to text context
    - Verify all messages updated to reference "termo" instead of "número"
    - Verify color scheme maintained (Cyan, Yellow, Green, Red)
    - _Requirements: 7.3, 7.4_
  
  - [ ] 12.2 Verify backward compatibility
    - Test that numeric searches still work (numbers are valid text)
    - Verify existing input format (comma/space separated) still works
    - _Requirements: 1.1, 1.2, 1.3_
  
  - [ ] 12.3 Final manual testing
    - Run script with various text inputs
    - Verify user experience is smooth and intuitive
    - Verify error messages are clear and helpful
    - _Requirements: 1.4, 7.1, 7.2, 7.3, 7.4_

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The script uses PowerShell as the implementation language
- Core performance optimization (`cmd.exe dir`) is preserved throughout
- All changes maintain backward compatibility with numeric searches
