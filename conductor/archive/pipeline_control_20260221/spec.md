# Specification - Pipeline Control Parameters

## Overview
This track introduces granular control over the synchronization pipeline in `Invoke-EvergreenLibrarySync.ps1`. Users will be able to specify how far an application should proceed through the automated workflow (Download, PSADT Packaging, IntuneWin Conversion).

## Functional Requirements
1. **Pipeline Control Parameter:** Introduce a `-StopAtPhase` parameter to `Invoke-EvergreenLibrarySync.ps1`.
2. **Phase Definitions:** Supported phases for `-StopAtPhase` include:
    - `Download`: Stop after retrieving the raw installer.
    - `PSADT`: Stop after creating the PSADT package.
    - `IntuneWin`: (Implicit default) Complete the full pipeline.
3. **Execution Logic:** 
    - If `-StopAtPhase Download` is used, skip all packaging and conversion logic.
    - If `-StopAtPhase PSADT` is used, skip the IntuneWin conversion logic.
4. **Default Behavior:** If the parameter is omitted, the script continues to perform the full end-to-end pipeline (Download -> PSADT -> IntuneWin).
5. **Validation:** Validate that the provided phase name is valid.

## Technical Constraints
- Must use PowerShell parameter validation (`ValidateSet`).
- Must not break existing automated triggers in the loop.

## Acceptance Criteria
- Running `Invoke-EvergreenLibrarySync.ps1 -StopAtPhase Download` results in only installers being updated in the `Installers/` folder.
- Running `Invoke-EvergreenLibrarySync.ps1 -StopAtPhase PSADT` results in installers being updated and PSADT packages being created, but no `.intunewin` files generated.
- Standard execution (no parameters) still completes the full pipeline.
- Invalid phase names result in a clear PowerShell error.
