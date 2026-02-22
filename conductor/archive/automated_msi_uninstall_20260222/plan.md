# Implementation Plan - Automated MSI Uninstallation Logic

## Phase 1: Core Logic Refactoring [checkpoint: 52bde4d]
- [x] **Task: Update Set-PSADTUninstallCommand Helper** e02e26a
    - [x] Write Unit Test: Add tests to `Tests/PSADTFunctions.Tests.ps1` to verify automated MSI and EXE uninstall string generation. e02e26a
    - [x] Implement Refactor: Update `Set-PSADTUninstallCommand` in `Scripts/PSADTFunctions.ps1` to accept `-InstallerName` and implement the automated logic. e02e26a
- [x] **Task: Conductor - User Manual Verification 'Phase 1: Core Logic Refactoring' (Protocol in workflow.md)**

## Phase 2: Pipeline Integration
- [x] **Task: Update Sync Scripts** 83ee2a7
    - [x] Implement Feature: Update `Invoke-EvergreenLibrarySync.ps1` to pass the `-InstallerName` to `Set-PSADTUninstallCommand`. 83ee2a7
    - [x] Implement Feature: Update `Invoke-LocalPackageSync.ps1` to pass the `-InstallerName` to `Set-PSADTUninstallCommand`. 83ee2a7
- [ ] **Task: Conductor - User Manual Verification 'Phase 2: Pipeline Integration' (Protocol in workflow.md)**

## Phase 3: Configuration & Cleanup [checkpoint: e35fcf4]
- [x] **Task: Refactor DeploymentConfig.json** 4417431
    - [x] Implement Chore: Remove standard `UninstallCommand` entries for MSI-based applications. 4417431
- [x] **Task: Conductor - User Manual Verification 'Phase 3: Configuration & Cleanup' (Protocol in workflow.md)**
