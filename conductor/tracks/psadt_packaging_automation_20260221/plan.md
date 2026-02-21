# Implementation Plan - PSADT Packaging Automation

## Phase 1: Core Package Staging
- [ ] **Task: Implement PSADT Template Management**
    - [ ] Write Tests: Verify the PSADT template source exists and can be copied to a target.
    - [ ] Implement Feature: Create a function `Copy-PSADTTemplate` to stage the base toolkit structure.
- [ ] **Task: Implement Package Naming & Organization**
    - [ ] Write Tests: Verify that illegal characters are sanitized and the correct folder name is generated.
    - [ ] Implement Feature: Create `Get-PSADTPackageName` for consistent naming: `<Vendor>_<AppName>_<Version>_<Arch>`.
- [ ] **Task: Implement Installer Staging**
    - [ ] Write Tests: Verify the installer file is moved to the `Files` subdirectory.
    - [ ] Implement Feature: Create `Staging-PSADTInstaller` to move the downloaded file to its deployment folder.
- [ ] **Task: Conductor - User Manual Verification 'Phase 1: Core Package Staging' (Protocol in workflow.md)**

## Phase 2: Metadata Injection
- [ ] **Task: Implement App Header Injection**
    - [ ] Write Tests: Verify `Invoke-AppDeployToolkit.ps1` header variables are correctly updated.
    - [ ] Implement Feature: Create `Set-PSADTAppHeader` to programmatically update `appVendor`, `appName`, `appVersion`, and `appArch`.
- [ ] **Task: Implement Dynamic Installer Selection Logic**
    - [ ] Write Tests: Verify the PSADT script correctly identifies the installer in the `Files` folder.
    - [ ] Implement Feature: Update the `Invoke-AppDeployToolkit.ps1` template to use a variable for the installer name.
- [ ] **Task: Conductor - User Manual Verification 'Phase 2: Metadata Injection' (Protocol in workflow.md)**

## Phase 3: Integration & Integration
- [ ] **Task: Integrate Packaging into Main Sync**
    - [ ] Write Tests: Verify that the main sync script triggers the packaging process after a successful download.
    - [ ] Implement Feature: Update `Invoke-EvergreenLibrarySync.ps1` to call the new PSADT packaging functions.
- [ ] **Task: Final Validation & Logging**
    - [ ] Write Tests: Verify the sync log records successful package creation.
    - [ ] Implement Feature: Update `Write-EvergreenSyncLog` to include PSADT packaging status and paths.
- [ ] **Task: Conductor - User Manual Verification 'Phase 3: Integration & Integration' (Protocol in workflow.md)**
