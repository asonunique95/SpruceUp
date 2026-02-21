# Implementation Plan - IntuneWin Conversion Automation

## Phase 1: Tool Setup and Basic Conversion
- [ ] **Task: Setup IntuneWinAppUtil Integration**
    - [ ] Implement Feature: Create a directory `Tools` and place (or instructions to place) `IntuneWinAppUtil.exe` inside it.
    - [ ] Implement Feature: Create a function `Get-IntuneWinAppUtilPath` to locate the executable.
- [ ] **Task: Implement Basic Conversion Function**
    - [ ] Implement Feature: Create `New-IntuneWinPackage` to wrap a PSADT folder into an `.intunewin` file using basic parameters.
- [ ] **Task: Conductor - User Manual Verification 'Phase 1: Tool Setup and Basic Conversion' (Protocol in workflow.md)**

## Phase 2: Advanced Conversion and Error Handling
- [ ] **Task: Implement Output Directory Management**
    - [ ] Implement Feature: Ensure the output directory for `.intunewin` files is automatically created and organized.
- [ ] **Task: Implement Resilience & Error Tracking**
    - [ ] Implement Feature: Add error handling for the packaging tool (e.g., handling missing source files or tool failures).
- [ ] **Task: Conductor - User Manual Verification 'Phase 2: Advanced Conversion and Error Handling' (Protocol in workflow.md)**

## Phase 3: Integration into Main Sync Script
- [ ] **Task: Integrate Conversion into Main Sync**
    - [ ] Implement Feature: Update `Invoke-EvergreenLibrarySync.ps1` to automatically trigger `.intunewin` conversion after successful PSADT packaging.
- [ ] **Task: Update Logging for Conversion**
    - [ ] Implement Feature: Update `Write-EvergreenSyncLog` to record the status and path of the generated `.intunewin` file.
- [ ] **Task: Conductor - User Manual Verification 'Phase 3: Integration into Main Sync Script' (Protocol in workflow.md)**
