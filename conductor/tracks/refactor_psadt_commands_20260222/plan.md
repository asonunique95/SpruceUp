# Implementation Plan - Refactor PSADT Deployment Commands

## Phase 1: Core Logic & Config Refactoring
- [x] **Task: Update Set-PSADTInstallCommand Helper** 5668d9b
    - [x] Write Unit Test: Create a test in `Tests/PSADTFunctions.Tests.ps1` to verify that `Set-PSADTInstallCommand` uses `-ArgumentList` instead of `-Arguments`. 5668d9b
    - [x] Implement Refactor: Update `Set-PSADTInstallCommand` in `Scripts/PSADTFunctions.ps1` to use `-ArgumentList`. 5668d9b
- [x] **Task: Refactor DeploymentConfig.json** 5668d9b
    - [x] Implement Refactor: Search and replace all occurrences of `-Arguments` with `-ArgumentList` in `DeploymentConfig.json`. 5668d9b
- [ ] **Task: Conductor - User Manual Verification 'Phase 1: Core Logic & Config Refactoring' (Protocol in workflow.md)**

## Phase 2: System-Wide Validation
- [ ] **Task: Verify Generated Scripts**
    - [ ] Manual Verification: Run a sync for a representative app (e.g., GoogleChrome) and confirm the resulting `Invoke-AppDeployToolkit.ps1` uses the correct parameter naming.
- [ ] **Task: Conductor - User Manual Verification 'Phase 2: System-Wide Validation' (Protocol in workflow.md)**
