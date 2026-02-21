# Specification - Improve Onboarding Tools UX

## Overview
This track focuses on making the application onboarding process more robust and user-friendly. It addresses issues in discovering application names, lack of visibility into metadata during filter testing, and the disconnected workflow between finding an app and adding it to the library.

## Functional Requirements
1. **Robust Discovery:** Refactor `Find-EvergreenLibraryApp.ps1` to handle search errors gracefully. If a wildcard search fails, try an exact match. Ensure meaningful error messages are shown if the `Evergreen` module returns no results or throws exceptions.
2. **Metadata Transparency:** Update `Test-EvergreenLibraryFilter.ps1` to display a summary of the *first matching object's* key properties (Vendor, Type, Architecture, etc.) whenever a filter is applied. This provides the user with the exact information needed for the `Add-EvergreenLibraryApp.ps1` script.
3. **Property Schema Display:** Ensure that `Find-EvergreenLibraryApp.ps1` consistently shows the property schema for matching apps so users know what they can filter on.
4. **Improved Feedback:** Use standard PowerShell error and warning streams effectively to guide the user when inputs are invalid.

## Technical Constraints
- Must remain compatible with existing PowerShell scripts.
- Must leverage the `Evergreen` module functions efficiently.

## Acceptance Criteria
- `Find-EvergreenLibraryApp.ps1 -Name "mozilla"` returns results or a clear "no match" instead of generic PowerShell errors.
- `Test-EvergreenLibraryFilter.ps1` shows the Vendor/Publisher of the matched application.
- All onboarding scripts have consistent naming and error handling.
