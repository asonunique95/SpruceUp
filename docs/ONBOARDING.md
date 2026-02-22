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

## Manual Application Import (Sideloading)

If you have an application that is not tracked by the Evergreen module (e.g., an internal line-of-business app), you can "sideload" it into the pipeline using `Invoke-LocalPackageSync.ps1`. This allows you to leverage the same PSADT wrapping and IntuneWin conversion logic used for automated apps.

### Usage
Run the script from the project root and provide the mandatory metadata and the path to your installer:

```powershell
.\Invoke-LocalPackageSync.ps1 -AppName "MyCustomApp" `
                             -Vendor "InternalIT" `
                             -Version "2.1.0" `
                             -SourcePath "C:\Downloads\setup.exe"
```

**Key Features:**
- **Automatic Configuration Creation:** If an entry for `MyCustomApp` does not exist in `DeploymentConfig.json`, the script will automatically create a default one for you. This allows you to easily customize its deployment for future updates.
- **Full Pipeline Integration:** The script performs the PSADT staging, metadata injection, and `.intunewin` conversion in a single step.

---

## Customizing Deployment

For more advanced scenarios, you can customize the installation and uninstallation logic by editing `DeploymentConfig.json`. This file allows you to specify custom PSADT commands and a list of processes that should be closed before installation.

### Configuration Structure
```json
"AppName": {
    "Vendor": "Publisher Name",
    "InstallCommand": "Start-ADTMsiProcess -FilePath \"$PSScriptRoot\\Files\\{InstallerName}\" -Action Install",
    "UninstallCommand": "Execute-MSI -Action Uninstall -Path \"{ProductCode}\"",
    "ProcessesToClose": ["process1", "process2"]
}
```

- **InstallCommand:** The full PowerShell command injected into the `Install` phase.
- **UninstallCommand:** The full PowerShell command injected into the `Uninstall` phase.
- **ProcessesToClose:** An array of process names (without .exe) to be terminated by the PSADT toolkit.

### Dynamic Placeholders
The following placeholders can be used in your commands and will be automatically replaced by the synchronization engine:

| Placeholder | Description | Example |
| :--- | :--- | :--- |
| **`{InstallerName}`** | The filename of the retrieved installer (e.g., `GoogleChrome_121.0_x64.msi`). | `Start-ADTMsiProcess -FilePath "$PSScriptRoot\Files\{InstallerName}"` |
| **`{ProductCode}`** | (Future) The MSI ProductCode of the installed application. | `Execute-MSI -Action Uninstall -Path "{ProductCode}"` |


---

## Controlling the Pipeline

By default, the sync script performs the full end-to-end process. You can use the `-StopAtPhase` parameter to stop earlier if you only want to download installers or create PSADT packages without converting them to Intune.

- **Download only:** `.\Invoke-EvergreenLibrarySync.ps1 -StopAtPhase Download`
- **Download & PSADT only:** `.\Invoke-EvergreenLibrarySync.ps1 -StopAtPhase PSADT`

---

## Common Filter Examples

| Scenario | Filter Pattern |
| :--- | :--- |
| **Stable x64 MSI** | `$_.Channel -eq 'Stable' -and $_.Architecture -eq 'x64' -and $_.Type -eq 'msi'` |
| **Latest EXE** | `$_.Type -eq 'exe'` |
| **Specific Edition** | `$_.Edition -eq 'Professional'` |
| **Language Specific** | `$_.Language -eq 'en-US'` |
| **Exclude Preview** | `$_.Channel -ne 'Beta' -and $_.Channel -ne 'Dev'` |
