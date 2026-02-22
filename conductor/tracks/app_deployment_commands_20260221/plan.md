# Implementation Plan - App-Specific Deployment Commands

## Phase 1: Core Configuration & Library Updates [checkpoint: 0307ab4]
- [x] **Task: Define and Update DeploymentConfig.json Schema** 8ebb86b
    - [x] Implement Feature: Update `DeploymentConfig.json` with sample `InstallCommand` and `UninstallCommand` entries for at least one app (e.g., 7Zip). 8ebb86b
- [x] **Task: Update PSADT Functions for Custom Commands** a735d91
    - [x] Implement Feature: Refactor `Set-PSADTInstallCommand` in `Scripts/PSADTFunctions.ps1` to accept an optional `CustomCommand`. a735d91
    - [x] Implement Feature: Create `Set-PSADTUninstallCommand` in `Scripts/PSADTFunctions.ps1` to inject custom uninstallation logic. a735d91
- [x] **Task: Conductor - User Manual Verification 'Phase 1: Core Configuration & Library Updates' (Protocol in workflow.md)** 0307ab4

## Phase 2: Pipeline Integration & Refactoring [checkpoint: 3191359]
- [x] **Task: Update Main Sync Script to load Deployment Config** 32c1843
    - [x] Implement Feature: Update `Invoke-EvergreenLibrarySync.ps1` to load `DeploymentConfig.json`. 32c1843
    - [x] Implement Feature: Pass app-specific commands and process lists to the packaging functions. 32c1843
- [x] **Task: Conductor - User Manual Verification 'Phase 2: Pipeline Integration & Refactoring' (Protocol in workflow.md)** 3191359

## Phase 3: Documentation & Expansion
- [ ] **Task: Update Onboarding Guide**
    - [ ] Implement Feature: Update `docs/ONBOARDING.md` to explain how to define custom commands in `DeploymentConfig.json`.
- [ ] **Task: Conductor - User Manual Verification 'Phase 3: Documentation & Expansion' (Protocol in workflow.md)**
