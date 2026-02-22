# Specification - Automated MSI Uninstallation Logic

This track refactors the PSADT uninstallation logic to automatically generate the correct command for MSI-based installers, ensuring consistency across all packages and reducing manual configuration in `DeploymentConfig.json`.

## 🎯 Goal
Automate the generation of MSI uninstallation commands using the original installer file stored in the PSADT `Files` directory, while providing a fallback template for EXE-based installers.

## 🛠️ Functional Requirements
1. **Helper Function Refactoring (`Scripts/PSADTFunctions.ps1`):**
    - Update `Set-PSADTUninstallCommand` to accept an additional mandatory parameter: `-InstallerName`.
    - Implement logic to automatically replace `{InstallerName}` in custom commands.
    - Implement default generation logic when no `CustomCommand` is provided:
        - **If MSI:** Use `Start-ADTMsiProcess -Action Uninstall -FilePath "$PSScriptRoot\Files\{InstallerName}" -ArgumentList "/qn /norestart"`.
        - **If EXE:** Use a generic template: `Start-ADTProcess -FilePath "$PSScriptRoot\Files\{InstallerName}" -ArgumentList "/uninstall"`.
2. **Pipeline Integration:**
    - Update `Invoke-EvergreenLibrarySync.ps1` and `Invoke-LocalPackageSync.ps1` to pass the `-InstallerName` to `Set-PSADTUninstallCommand`.
    - Ensure `Set-PSADTUninstallCommand` is called even if no custom uninstall command is defined in the config.
3. **Configuration Cleanup (`DeploymentConfig.json`):**
    - Remove hardcoded `UninstallCommand` entries for MSI applications where the automated logic can now provide the standard command.

## 📋 Acceptance Criteria
- MSI packages now contain an uninstallation task that points to the installer file in the `Files` folder.
- `DeploymentConfig.json` is leaner, containing only unique or non-standard uninstallation logic.
- `{InstallerName}` is dynamically resolved in both automated and custom uninstallation strings.

## 🚫 Out of Scope
- Implementing automatic `ProductCode` detection (this remains a future improvement).
- Handling complex multi-file uninstallation logic automatically.
