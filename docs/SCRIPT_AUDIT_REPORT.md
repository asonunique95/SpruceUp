# Script Audit Report - February 2026

This report provides a comprehensive overview of the scripts located in the `/Scripts` directory and their current usage within the SpruceUp project.

## Audit Summary

| Script Name | Usage Status | References Found | Recommendation |
| :--- | :--- | :--- | :--- |
| **Add-EvergreenLibraryApp.ps1** | **Active** | README.md, docs/ONBOARDING.md, Test-EvergreenLibraryFilter.ps1 | Keep |
| **Find-EvergreenLibraryApp.ps1** | **Active** | README.md, docs/ONBOARDING.md | Keep |
| **Get-EvergreenSync.ps1** | **Legacy** | Sync-Evergreen.ps1 (Legacy Entry Point) | Safe to Archive/Remove |
| **IntuneWinFunctions.ps1** | **Active** | Invoke-EvergreenLibrarySync.ps1, Invoke-LocalPackageSync.ps1 | Keep |
| **LibraryFunctions.ps1** | **Active** | Invoke-EvergreenLibrarySync.ps1, Invoke-LocalPackageSync.ps1, Tests/*.Tests.ps1 | Keep |
| **New-PSADTPackage.ps1** | **Legacy** | Sync-Evergreen.ps1 (Legacy Entry Point) | Safe to Archive/Remove |
| **PSADTFunctions.ps1** | **Active** | Invoke-EvergreenLibrarySync.ps1, Invoke-LocalPackageSync.ps1, Tests/*.Tests.ps1 | Keep |
| **Test-EvergreenLibraryFilter.ps1** | **Active** | README.md, docs/ONBOARDING.md | Keep |
| **Write-SyncLog.ps1** | **Legacy** | Sync-Evergreen.ps1 (Legacy Entry Point) | Safe to Archive/Remove |

## Root Scripts Audit

| Script Name | Usage Status | References Found | Recommendation |
| :--- | :--- | :--- | :--- |
| **Invoke-EvergreenLibrarySync.ps1** | **Primary** | README.md, Project Manifests | Keep (Primary Entry Point) |
| **Invoke-LocalPackageSync.ps1** | **Active** | README.md, docs/ONBOARDING.md | Keep (Secondary Entry Point) |
| **Sync-Evergreen.ps1** | **Legacy** | .gitignore | Safe to Archive/Remove |

## Detailed Analysis

### Legacy Chain
The following scripts form a legacy chain that was used before the `Invoke-EvergreenLibrarySync.ps1` refactor:
1. `Sync-Evergreen.ps1` (Main entry point)
2. `Scripts/Get-EvergreenSync.ps1` (Helper)
3. `Scripts/New-PSADTPackage.ps1` (Helper)
4. `Scripts/Write-SyncLog.ps1` (Helper - old CSV logger)

These scripts are **not** referenced in the current documentation (README/ONBOARDING) and are not used by the modern `Invoke-*` scripts. They still use `Write-Host` for output and lack the advanced logging (`Write-SpruceLog`) and IntuneWin conversion features of the current pipeline.

### Active Chain
The following scripts are fully integrated into the current pipeline and are essential for operation:
- `Invoke-EvergreenLibrarySync.ps1`
- `Invoke-LocalPackageSync.ps1`
- `Scripts/LibraryFunctions.ps1`
- `Scripts/PSADTFunctions.ps1`
- `Scripts/IntuneWinFunctions.ps1`
- `Scripts/Add-EvergreenLibraryApp.ps1`
- `Scripts/Find-EvergreenLibraryApp.ps1`
- `Scripts/Test-EvergreenLibraryFilter.ps1`
