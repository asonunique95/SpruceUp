# Implementation Plan - Dynamic Installer Placeholders

## Phase 1: Core Logic Refactoring
- [ ] **Task: Update Set-PSADTInstallCommand**
    - [ ] Implement Feature: Add string replacement logic to `Set-PSADTInstallCommand` to swap `{InstallerName}` with the actual `$InstallerName` value.
- [ ] **Task: Update DeploymentConfig.json**
    - [ ] Implement Feature: Refactor all `InstallCommand` entries in `DeploymentConfig.json` to use the `{InstallerName}` placeholder.
- [ ] **Task: Conductor - User Manual Verification 'Phase 1: Core Logic Refactoring' (Protocol in workflow.md)**

## Phase 2: Documentation & Final Integration
- [ ] **Task: Update Onboarding Guide**
    - [ ] Implement Feature: Update `docs/ONBOARDING.md` to document the use of `{InstallerName}` in custom commands.
- [ ] **Task: Conductor - User Manual Verification 'Phase 2: Documentation & Final Integration' (Protocol in workflow.md)**
