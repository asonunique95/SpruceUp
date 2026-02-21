# Onboarding New Applications

This guide explains how to add new enterprise applications to your automated pipeline using the provided helper scripts.

## Overview

The onboarding process involves three main steps:
1. **Discovery:** Finding the correct application name in the Evergreen module.
2. **Filter Testing:** Crafting a PowerShell filter to target specific versions, channels, or architectures.
3. **Registration:** Automatically adding the validated configuration to `EvergreenLibrary.json`.

---

## Step 1: Discover the Application

Use `Find-EvergreenLibraryApp.ps1` to search for the application. The script is robust and tries both wildcard and literal matches.

```powershell
.\Scripts\Find-EvergreenLibraryApp.ps1 -Name "mozilla"
```

**Key Features:**
- Lists all matching applications.
- If a single match is found, it displays the **Available Properties** you can use for filtering (e.g., `Channel`, `Version`, `Architecture`, `Type`, `Language`).
- Shows **Sample Data** for the app to help you understand the values you're filtering for.

---

## Step 2: Test your Filters

Once you have the `EvergreenApp` name, use `Test-EvergreenLibraryFilter.ps1` to interactively refine your filter.

```powershell
.\Scripts\Test-EvergreenLibraryFilter.ps1 -EvergreenApp "MozillaFirefox"
```

**How it works:**
- Enter your filter string (e.g., `$_.Channel -eq 'Stable' -and $_.Architecture -eq 'x64'`).
- The script displays matching records and a **Matched Metadata Summary**.
- **Crucial:** The summary shows the `Vendor` and `EvergreenApp` values you'll need for Step 3.
- Type `done` to finish once you are happy with the results.

---

## Step 3: Add to the Library

Finally, use `Add-EvergreenLibraryApp.ps1` to register the application. It automatically handles duplicates and keeps the manifest sorted alphabetically.

```powershell
.\Scripts\Add-EvergreenLibraryApp.ps1 -Name "Firefox" `
                                     -Vendor "Mozilla" `
                                     -EvergreenApp "MozillaFirefox" `
                                     -Filter '$_.Channel -eq "Stable" -and $_.Architecture -eq "x64"'
```

**Parameters:**
- `-Name`: Your preferred friendly name (this will be the folder name in `Installers/`).
- `-Vendor`: The publisher name (found in Step 2 summary).
- `-EvergreenApp`: The exact name (found in Step 1 or 2).
- `-Filter`: The validated string from Step 2.

---

## Common Filter Examples

| Scenario | Filter Pattern |
| :--- | :--- |
| **Stable x64 MSI** | `$_.Channel -eq 'Stable' -and $_.Architecture -eq 'x64' -and $_.Type -eq 'msi'` |
| **Latest EXE** | `$_.Type -eq 'exe'` |
| **Specific Edition** | `$_.Edition -eq 'Professional'` |
| **Language Specific** | `$_.Language -eq 'en-US'` |
| **Exclude Preview** | `$_.Channel -ne 'Beta' -and $_.Channel -ne 'Dev'` |
