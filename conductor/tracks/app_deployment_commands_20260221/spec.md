# Specification - App-Specific Deployment Commands

## Overview
This track enables the injection of application-specific installation and uninstallation commands into the PSADT scripts. These commands will be managed in `DeploymentConfig.json`, allowing the automated pipeline to create ready-to-use deployment packages tailored to each application's unique requirements.

## Functional Requirements
1. **Expanded Configuration:** Leverage `DeploymentConfig.json` to store full PowerShell commands for both installation and uninstallation.
2. **Schema Update:** The JSON structure for each app will be updated to support:
    - `InstallCommand`: The exact PSADT command to run during installation (e.g., `Start-ADTMsiProcess -FilePath "$PSScriptRoot\Files\installer.msi" -Action Install`).
    - `UninstallCommand`: The exact PSADT command to run during uninstallation.
3. **Smart Injection:** Update `Scripts/PSADTFunctions.ps1` to:
    - Prefer the `InstallCommand` from `DeploymentConfig.json` if it exists.
    - Fall back to the current generic logic if no specific command is defined.
    - Inject the `UninstallCommand` into the corresponding `## <Perform Uninstallation tasks here>` section of the PSADT script.
4. **Main Script Integration:** Update `Invoke-EvergreenLibrarySync.ps1` to load the deployment configuration and pass the correct commands to the packaging functions.

## Technical Constraints
- The `InstallCommand` and `UninstallCommand` must be valid PowerShell/PSADT syntax.
- The system must handle the replacement of placeholders or variables if necessary (though storing full commands is preferred).

## Acceptance Criteria
- Running a sync for an application with a defined `InstallCommand` in `DeploymentConfig.json` results in that exact command being injected into `Invoke-AppDeployToolkit.ps1`.
- If no command is defined, the existing generic MSI/EXE logic is used.
- The uninstallation section of the generated PSADT script is correctly populated if a command is provided.
