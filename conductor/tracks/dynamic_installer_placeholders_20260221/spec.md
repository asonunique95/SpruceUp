# Specification - Dynamic Installer Placeholders

## Overview
This track refactors the way installation commands are stored and injected to ensure that new application versions are handled automatically without needing manual updates to `DeploymentConfig.json`.

## Functional Requirements
1. **Placeholder Support:** Introduce the `{InstallerName}` placeholder for use within the `InstallCommand` field in `DeploymentConfig.json`.
2. **Dynamic Injection:** Update `Set-PSADTInstallCommand` in `Scripts/PSADTFunctions.ps1` to automatically replace `{InstallerName}` with the filename of the retrieved installer.
3. **Configuration Refactoring:** Update all existing entries in `DeploymentConfig.json` to use the dynamic placeholder instead of hardcoded version-specific filenames.
4. **Resilience:** Ensure that if the placeholder is missing, the script provides a helpful warning or fallback.

## Technical Constraints
- The replacement logic must be case-insensitive.
- Must support both MSI and EXE installers.

## Acceptance Criteria
- Running a sync for a new version of 7-Zip (e.g., `7z2700-x64.msi`) correctly injects the new filename into the PSADT script even if the config file was created for an older version.
- `DeploymentConfig.json` contains no hardcoded version numbers in `InstallCommand` strings.
