# Implementation Plan - Automated MSI Uninstallation Logic

## Phase 1: Core Logic Refactoring
- [x] **Task: Update Set-PSADTUninstallCommand Helper** e02e26a
    - [x] Write Unit Test: Add tests to `Tests/PSADTFunctions.Tests.ps1` to verify automated MSI and EXE uninstall string generation. e02e26a
    - [x] Implement Refactor: Update `Set-PSADTUninstallCommand` in `Scripts/PSADTFunctions.ps1` to accept `-InstallerName` and implement the automated logic. e02e26a
- [ ] **Task: Conductor - User Manual Verification 'Phase 1: Core Logic Refactoring' (Protocol in workflow.md)**

## Phase 2: Pipeline Integration
- [ ] **Task: Update Sync Scripts**
    - [ ] Implement Feature: Update `Invoke-EvergreenLibrarySync.ps1` to pass the `-InstallerName` to `Set-PSADTUninstallCommand`.
    - [ ] Implement Feature: Update `Invoke-LocalPackageSync.ps1` to pass the `-InstallerName` to `Set-PSADTUninstallCommand`.
- [ ] **Task: Conductor - User Manual Verification 'Phase 2: Pipeline Integration' (Protocol in workflow.md)**

## Phase 3: Configuration & Cleanup
- [ ] **Task: Refactor DeploymentConfig.json**
    - [ ] Implement Chore: Remove standard `UninstallCommand` entries for MSI-based applications.
- [ ] **Task: Conductor - User Manual Verification 'Phase 3: Configuration & Cleanup' (Protocol in workflow.md)**
