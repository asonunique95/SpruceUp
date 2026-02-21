# Implementation Plan - PSADT Packaging Automation

## Phase 1: Core Package Staging [checkpoint: d600044]
- [x] **Task: Implement PSADT Template Management** 7a53d86
    - [x] Write Tests: Verify the PSADT template source exists and can be copied to a target. 7a53d86
    - [x] Implement Feature: Create a function `Copy-PSADTTemplate` to stage the base toolkit structure. 7a53d86
- [x] **Task: Implement Package Naming & Organization** 7a53d86
    - [x] Write Tests: Verify that illegal characters are sanitized and the correct folder name is generated. 7a53d86
    - [x] Implement Feature: Create `Get-PSADTPackageName` for consistent naming: `<Vendor>_<AppName>_<Version>_<Arch>`. 7a53d86
- [x] **Task: Implement Installer Staging** 7a53d86
    - [x] Write Tests: Verify the installer file is moved to the `Files` subdirectory. 7a53d86
    - [x] Implement Feature: Create `Staging-PSADTInstaller` to move the downloaded file to its deployment folder. 7a53d86
- [x] **Task: Conductor - User Manual Verification 'Phase 1: Core Package Staging' (Protocol in workflow.md)** d600044

## Phase 2: Metadata Injection
- [x] **Task: Implement App Header Injection** 6ad35d5
    - [x] Write Tests: Verify `Invoke-AppDeployToolkit.ps1` header variables are correctly updated. 6ad35d5
    - [x] Implement Feature: Create `Set-PSADTAppHeader` to programmatically update `appVendor`, `appName`, `appVersion`, and `appArch`. 6ad35d5
- [x] **Task: Implement Dynamic Installer Selection Logic** 6ad35d5
    - [x] Write Tests: Verify the PSADT script correctly identifies the installer in the `Files` folder. 6ad35d5
    - [x] Implement Feature: Update the `Invoke-AppDeployToolkit.ps1` template to use a variable for the installer name. 6ad35d5
- [~] **Task: Conductor - User Manual Verification 'Phase 2: Metadata Injection' (Protocol in workflow.md)**

## Phase 3: Integration & Integration
- [ ] **Task: Integrate Packaging into Main Sync**
    - [ ] Write Tests: Verify that the main sync script triggers the packaging process after a successful download.
    - [ ] Implement Feature: Update `Invoke-EvergreenLibrarySync.ps1` to call the new PSADT packaging functions.
- [ ] **Task: Final Validation & Logging**
    - [ ] Write Tests: Verify the sync log records successful package creation.
    - [ ] Implement Feature: Update `Write-EvergreenSyncLog` to include PSADT packaging status and paths.
- [ ] **Task: Conductor - User Manual Verification 'Phase 3: Integration & Integration' (Protocol in workflow.md)**
