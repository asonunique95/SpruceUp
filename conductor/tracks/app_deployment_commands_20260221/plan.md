# Implementation Plan - App-Specific Deployment Commands

## Phase 1: Core Configuration & Library Updates
- [x] **Task: Define and Update DeploymentConfig.json Schema** 8ebb86b
    - [x] Implement Feature: Update `DeploymentConfig.json` with sample `InstallCommand` and `UninstallCommand` entries for at least one app (e.g., 7Zip). 8ebb86b
- [x] **Task: Update PSADT Functions for Custom Commands** a735d91
    - [x] Implement Feature: Refactor `Set-PSADTInstallCommand` in `Scripts/PSADTFunctions.ps1` to accept an optional `CustomCommand`. a735d91
    - [x] Implement Feature: Create `Set-PSADTUninstallCommand` in `Scripts/PSADTFunctions.ps1` to inject custom uninstallation logic. a735d91
- [~] **Task: Conductor - User Manual Verification 'Phase 1: Core Configuration & Library Updates' (Protocol in workflow.md)**

## Phase 2: Pipeline Integration & Refactoring
- [ ] **Task: Update Main Sync Script to load Deployment Config**
    - [ ] Implement Feature: Update `Invoke-EvergreenLibrarySync.ps1` to load `DeploymentConfig.json`.
    - [ ] Implement Feature: Pass app-specific commands and process lists to the packaging functions.
- [ ] **Task: Conductor - User Manual Verification 'Phase 2: Pipeline Integration & Refactoring' (Protocol in workflow.md)**

## Phase 3: Documentation & Expansion
- [ ] **Task: Update Onboarding Guide**
    - [ ] Implement Feature: Update `docs/ONBOARDING.md` to explain how to define custom commands in `DeploymentConfig.json`.
- [ ] **Task: Conductor - User Manual Verification 'Phase 3: Documentation & Expansion' (Protocol in workflow.md)**
