# Implementation Plan - Advanced Logging System

## Phase 1: Unified Logging Core [checkpoint: a40c669]
- [x] **Task: Create Write-SpruceLog Helper** a530992
    - [x] Write Unit Test: Create a test in `Tests/Logging.Tests.ps1` to verify log file creation and formatting. a530992
    - [x] Implement Feature: Refactor `Scripts/LibraryFunctions.ps1` or create a new script to house `Write-SpruceLog` with support for both `.log` and `.csv` outputs. a530992
- [x] **Task: Conductor - User Manual Verification 'Phase 1: Unified Logging Core' (Protocol in workflow.md)**

## Phase 2: Pipeline Refactoring
- [ ] **Task: Update Invoke-EvergreenLibrarySync.ps1**
    - [ ] Implement Feature: Replace all `Write-Host` and old logging calls with `Write-SpruceLog`. Ensure discovery, download, and conversion steps are individually logged.
- [ ] **Task: Update Invoke-LocalPackageSync.ps1**
    - [ ] Implement Feature: Integrate `Write-SpruceLog` into the manual import process.
- [ ] **Task: Conductor - User Manual Verification 'Phase 2: Pipeline Refactoring' (Protocol in workflow.md)**

## Phase 3: Documentation & Cleanup
- [ ] **Task: Update README & Docs**
    - [ ] Implement Feature: Update documentation to reflect the new log file locations and formats.
- [ ] **Task: Cleanup Old Scripts**
    - [ ] Implement Chore: Remove `Scripts/Write-SyncLog.ps1` if it is no longer used.
- [ ] **Task: Conductor - User Manual Verification 'Phase 3: Documentation & Cleanup' (Protocol in workflow.md)**
