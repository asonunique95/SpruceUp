# Specification - PSADT Packaging Automation

## Overview
This track focuses on automating the creation of PowerShell App Deployment Toolkit (PSADT) packages for applications retrieved via the Evergreen module. The goal is to transform a raw installer file into a ready-to-deploy PSADT package with all necessary configurations automatically injected.

## User Stories
- **As a System Administrator**, I want to automatically wrap my downloaded installers in a PSADT template so that I don't have to manually create the deployment structure for every app.
- **As a DevOps Engineer**, I want the PSADT configuration script (`Invoke-AppDeployToolkit.ps1`) to be pre-populated with the correct application metadata (Name, Vendor, Version) for consistency and to avoid human error.

## Functional Requirements
1. **PSADT Template Management:** Maintain and copy a standardized PSADT base template for each new package.
2. **Package Naming & Organization:** Create a new package directory using a consistent naming convention: `<Vendor>_<AppName>_<Version>_<Architecture>`.
3. **Installer Staging:** Move the downloaded installer file from its Evergreen-organized path into the `Files` subdirectory of the newly created PSADT package.
4. **Metadata Injection:** Programmatically update the `Invoke-AppDeployToolkit.ps1` script's header variables (`appVendor`, `appName`, `appVersion`, `appArch`) with values from the Evergreen sync process.
5. **Support File Staging:** (Optional/Future) Copy additional support files or custom scripts into the package if specified in the manifest.

## Technical Constraints
- Must be implemented in PowerShell.
- Must respect the internal directory structure and variable naming conventions of the PSADT (PowerShell App Deployment Toolkit).
- Must handle character sanitization for folder names (e.g., removing spaces or illegal characters if necessary).

## Success Criteria
- The script successfully creates a complete PSADT package structure for a given application.
- The `Files` folder in the package contains the correct installer.
- The `Invoke-AppDeployToolkit.ps1` script has the correct metadata in its header variables.
- The resulting package folder name follows the defined naming convention.
