# Implementation Plan - External Storage Support

## Phase 1: Script Logic Update
- [x] **Task: Update Invoke-EvergreenLibrarySync.ps1 with -DataPath** 7feefe2
    - [x] Implement Feature: Add a `-DataPath` parameter to `Invoke-EvergreenLibrarySync.ps1` and decouple `$LibraryPath` (for config) from `$DataPath` (for downloads/packages). 7feefe2
- [x] **Task: Update Invoke-LocalPackageSync.ps1 with -DataPath** 7feefe2
    - [x] Implement Feature: Add a `-DataPath` parameter to `Invoke-LocalPackageSync.ps1` and ensure it correctly handles the redirected output folders. 7feefe2
- [ ] **Task: Conductor - User Manual Verification 'Phase 1: Script Logic Update' (Protocol in workflow.md)**

## Phase 2: Documentation & Testing
- [ ] **Task: Update Onboarding Guide**
    - [ ] Implement Feature: Update `docs/ONBOARDING.md` to document the use of the `-DataPath` parameter for external storage and SMB shares.
- [ ] **Task: Conductor - User Manual Verification 'Phase 2: Documentation & Testing' (Protocol in workflow.md)**
