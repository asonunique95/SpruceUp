# Specification - Refactor PSADT Deployment Commands

This track focuses on correcting the parameter names in the PSADT-related helper functions and configurations to ensure they align with the expected PSADT command syntax (specifically using `-ArgumentList` instead of `-Arguments`).

## 🎯 Goal
Improve the reliability and accuracy of generated PSADT scripts by ensuring all deployment-related PowerShell commands use the correct and consistent parameter names.

## 🛠️ Functional Requirements
1. **Helper Function Refactoring:**
    - Update `Set-PSADTInstallCommand` in `Scripts/PSADTFunctions.ps1` to use `-ArgumentList` for default and custom command generation.
2. **Command Standardization:**
    - Ensure `Start-ADTMsiProcess` and `Start-ADTProcess` (when used in templates or generated strings) correctly utilize the `-ArgumentList` parameter.
3. **Configuration Synchronization:**
    - Refactor `DeploymentConfig.json` to replace all occurrences of `-Arguments` with `-ArgumentList` within `InstallCommand` and `UninstallCommand` strings.

## 📋 Acceptance Criteria
- Running `Invoke-EvergreenLibrarySync.ps1` or `Invoke-LocalPackageSync.ps1` results in `Invoke-AppDeployToolkit.ps1` files that use `-ArgumentList` for all process execution commands.
- `DeploymentConfig.json` contains no references to `-Arguments` for PSADT commands.
- The `Set-PSADTInstallCommand` function correctly handles both default logic and placeholder replacement using the new parameter naming.

## 🚫 Out of Scope
- Changing the core logic of the PSADT toolkit itself.
- Adding new PSADT wrapper functions beyond those currently managed by the project.
