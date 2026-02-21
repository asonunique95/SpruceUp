# Implementation Plan - Improve Onboarding Tools UX

## Phase 1: Robust Application Discovery [checkpoint: c25ff24]
- [x] **Task: Refactor Find-EvergreenLibraryApp.ps1** f889dda
    - [x] Implement Feature: Wrap `Find-EvergreenApp` in a try-catch block. f889dda
    - [x] Implement Feature: Improve search logic to try both wildcard and literal matches. f889dda
    - [x] Implement Feature: Ensure property schema is displayed clearly for single matches. f889dda
- [x] **Task: Conductor - User Manual Verification 'Phase 1: Robust Application Discovery' (Protocol in workflow.md)** c25ff24

## Phase 2: Enhanced Metadata Visibility
- [ ] **Task: Refactor Test-EvergreenLibraryFilter.ps1**
    - [ ] Implement Feature: Update the output table to include more metadata columns if available.
    - [ ] Implement Feature: Add a "Matched Metadata Summary" that shows Vendor/Publisher and other key fields from the first result.
- [ ] **Task: Conductor - User Manual Verification 'Phase 2: Enhanced Metadata Visibility' (Protocol in workflow.md)**

## Phase 3: Final Polishing & Documentation
- [ ] **Task: Update Add-EvergreenLibraryApp.ps1**
    - [ ] Implement Feature: Improve error handling and duplicate checking feedback.
- [ ] **Task: Update Onboarding Guide**
    - [ ] Implement Feature: Update `docs/ONBOARDING.md` with the new script behaviors and better examples.
- [ ] **Task: Conductor - User Manual Verification 'Phase 3: Final Polishing & Documentation' (Protocol in workflow.md)**
