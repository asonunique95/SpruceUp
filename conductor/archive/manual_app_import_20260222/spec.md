# Specification - Manual Application Import (Sideloading)

This track enables the ability to wrap local installers that are not sourced from the `Evergreen` module into the automated PSADT and IntuneWin pipeline.

## 🎯 Goal
Provide a new entry point that allows users to supply a local file and manual metadata, while still leveraging the existing packaging and conversion logic.

## 🛠️ Key Features
1. **New Entry Point:** Create `Invoke-LocalPackageSync.ps1` to handle manual imports.
2. **Metadata Injection:** Allow manual input for `AppName`, `Vendor`, `Version`, and `Architecture`.
3. **Config Integration:** Automatically lookup `DeploymentConfig.json` based on the manually provided `AppName`.
4. **Pipeline Reuse:** Reuse existing `PSADTFunctions.ps1` and `IntuneWinFunctions.ps1` to ensure consistency.

## 📋 Success Criteria
- Running `Invoke-LocalPackageSync.ps1` with a local `.exe` or `.msi` results in a fully wrapped PSADT package in the `Packages/` directory.
- The `{InstallerName}` placeholder in `DeploymentConfig.json` still works correctly for manual files.
- The final output is a valid `.intunewin` file.
