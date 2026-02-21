# Specification - IntuneWin Conversion Automation

## Overview
This track focuses on automating the conversion of PowerShell App Deployment Toolkit (PSADT) packages into `.intunewin` files using the Microsoft Intune Win32 App Packaging Tool (`IntuneWinAppUtil.exe`). This is the final step in the automated pipeline to prepare applications for upload to Microsoft Intune.

## User Stories
- **As a System Administrator**, I want to automatically convert my PSADT packages into `.intunewin` files so that I can directly upload them to Microsoft Intune without manual packaging.
- **As a DevOps Engineer**, I want the conversion process to be integrated into the main sync script so that I have a fully automated "Evergreen to Intune" pipeline.

## Functional Requirements
1. **Tool Integration:** Integrate and manage the `IntuneWinAppUtil.exe` executable within the project structure.
2. **Automated Conversion Function:** Create a PowerShell function to invoke the packaging tool with the correct parameters for a given PSADT folder.
3. **Output Management:** Standardize the output directory for generated `.intunewin` files (e.g., `Packages\IntuneWin`).
4. **Metadata Preservation:** Ensure the generated `.intunewin` file includes the correct setup file (`Invoke-AppDeployToolkit.exe`) and source folder.
5. **Batch Processing:** (Optional) Support batch conversion of multiple PSADT packages.

## Technical Constraints
- Must be implemented in PowerShell.
- Requires `IntuneWinAppUtil.exe` to be available (will need to be downloaded or provided).
- The packaging tool must be invoked with specific arguments: `-c` (source folder), `-s` (setup file), `-o` (output folder).

## Success Criteria
- The script successfully invokes `IntuneWinAppUtil.exe` and produces a valid `.intunewin` file for a sample PSADT package.
- The output file is placed in the designated directory.
- The main sync script can trigger this conversion automatically after a PSADT package is created.
