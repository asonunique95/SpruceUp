# Specification - Project Structure Reorganization

## Overview
This track refactors the project's folder hierarchy to improve cleanliness and organization. Currently, raw application downloads (e.g., `Google/`, `Adobe/`) are stored in the project root. This track will move these into a dedicated `Installers/` subfolder while keeping deployment artifacts in `Packages/`.

## User Stories
- **As a Developer**, I want the project root to remain clean and free of hundreds of downloaded folders so that I can easily find script files and documentation.
- **As a User**, I want a clear separation between raw installers and the processed deployment packages.

## Functional Requirements
1. **Introduction of `Installers/` Folder:** All folders created by the discovery/download process must now reside within an `Installers/` subdirectory of the main library path.
2. **Script Parameter Refactoring:** Update `Invoke-EvergreenLibrarySync.ps1` to distinguish between the Project Root (`$LibraryPath`) and the Installers Repository.
3. **Logic Update:** Ensure `Sync-EvergreenLibraryApp` correctly uses the new subfolder path when building application roots.
4. **Documentation Sync:** Update `README.md` and `docs/ONBOARDING.md` to reflect the new structure.

## Technical Constraints
- Must maintain backward compatibility or provide a clear path for existing installations.
- Must ensure relative pathing remains robust.

## Success Criteria
- Running a sync for a new app creates the folder structure under `Installers\<Publisher>\<AppName>...` instead of the root.
- Existing logic for PSADT packaging and IntuneWin conversion correctly finds the installers in the new location.
- The project root only contains scripts, core configuration files, and top-level directories (`Installers/`, `Packages/`, `Tools/`, `docs/`, `conductor/`).
