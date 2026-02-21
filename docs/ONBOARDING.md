# Onboarding New Applications

This guide explains how to add new enterprise applications to your automated pipeline using the provided helper scripts.

## Overview

The onboarding process involves three main steps:
1. **Discovery:** Finding the correct application name in the Evergreen module.
2. **Filter Testing:** Crafting a PowerShell filter to target specific versions, channels, or architectures.
3. **Registration:** Automatically adding the validated configuration to `EvergreenLibrary.json`.

---

## Step 1: Discover the Application

Use `Find-EvergreenLibraryApp.ps1` to search for the application.

```powershell
.\Scripts\Find-EvergreenLibraryApp.ps1 -Name "Chrome"
```

This script will:
- List all matching applications in the Evergreen module.
- If a single match is found, it will display the **Available Properties** you can use for filtering (e.g., `Channel`, `Version`, `Architecture`, `Type`).

---

## Step 2: Test your Filters

Once you have the `EvergreenApp` name, use `Test-EvergreenLibraryFilter.ps1` to interactively refine your filter.

```powershell
.\Scripts\Test-EvergreenLibraryFilter.ps1 -EvergreenApp "GoogleChrome"
```

**How it works:**
- The script enters an interactive loop.
- Type your filter string (e.g., `$_.Channel -eq 'Stable' -and $_.Architecture -eq 'x64'`).
- The script displays all records that match your filter.
- Continue refining until you are happy with the results.
- Type `done` to finish and see your final filter choice.

---

## Step 3: Add to the Library

Finally, use `Add-EvergreenLibraryApp.ps1` to register the application in `EvergreenLibrary.json`.

```powershell
.\Scripts\Add-EvergreenLibraryApp.ps1 -Name "GoogleChrome" `
                                     -Vendor "Google" `
                                     -EvergreenApp "GoogleChrome" `
                                     -Filter '$_.Channel -eq "Stable" -and $_.Architecture -eq "x64" -and $_.Type -eq "msi"'
```

**Parameters:**
- `-Name`: The friendly name used for your folder structure within the `Installers/` directory.
- `-Vendor`: The publisher name.
- `-EvergreenApp`: The exact name found in Step 1.
- `-Filter`: The validated string from Step 2.

---

## Common Filter Examples

| Scenario | Filter Pattern |
| :--- | :--- |
| **Stable x64 MSI** | `$_.Channel -eq 'Stable' -and $_.Architecture -eq 'x64' -and $_.Type -eq 'msi'` |
| **Latest EXE** | `$_.Type -eq 'exe'` |
| **Specific Edition** | `$_.Edition -eq 'Professional'` |
| **Exclude Preview** | `$_.Channel -ne 'Beta' -and $_.Channel -ne 'Dev'` |
