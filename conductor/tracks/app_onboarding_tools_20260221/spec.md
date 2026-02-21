# Specification - Application Onboarding Tools

## Overview
This track aims to simplify the process of adding new applications to the `EvergreenLibrary.json` manifest. It provides helper scripts for discovering application metadata, testing filters interactively, and automatically updating the manifest with validated configurations.

## Functional Requirements
1. **Application Discovery:** A script (`Find-EvergreenLibraryApp.ps1`) to search for application names within the `Evergreen` module and display available properties (e.g., Channels, Architectures, Types).
2. **Interactive Filter Testing:** A tool to allow users to input filter strings and see real-time matches from the `Evergreen` metadata to ensure they are targeting the correct installer.
3. **Automated Manifest Update:** A command to append a successfully validated application configuration (Name, Vendor, EvergreenApp, Filter) directly to the `EvergreenLibrary.json` file.
4. **Onboarding Documentation:** A dedicated guide (`docs/ONBOARDING.md`) explaining the manual and automated processes for adding apps, including common filtering patterns.

## Technical Constraints
- Must be implemented in PowerShell.
- Must leverage existing `Evergreen` module functions.
- Must ensure `EvergreenLibrary.json` remains a valid JSON file after automated updates.

## Acceptance Criteria
- User can search for "Chrome" and see "GoogleChrome" as a valid name.
- User can test a filter (e.g., `Channel -eq 'Stable'`) and see the matching file metadata.
- A new application can be added to the library file without manual text editing.
- Documentation provides clear examples for common publishers (Microsoft, Google, Adobe).

## Out of Scope
- Automated creation of Intune assignments (focused only on onboarding to the library).
- Validation of the installer's actual download URL (assumed correct if returned by Evergreen).
