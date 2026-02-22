# Evergreen Library Automation

A comprehensive PowerShell-based pipeline to automate the retrieval, packaging, and preparation of enterprise application installers for Microsoft Intune.

This tool leverages the [Evergreen](https://github.com/steve0hun/Evergreen) PowerShell module to ensure you always have the latest versions of common applications, wrapped in the industry-standard [PSAppDeployToolkit (PSADT)](https://psappdeploytoolkit.com/) and converted into `.intunewin` format.

## 🚀 Key Features

- **Automated Discovery:** Continuously monitors for new application versions using the `Evergreen` module.
- **Smart Sync:** Only downloads new or missing installers, saving bandwidth and storage.
- **Structured Organization:** Organizes installers into a clean `Installers\<Publisher>\<Application>\<Channel>\<Version>\<Architecture>` hierarchy.
- **Automated PSADT Wrapping:** Automatically stages a PSADT template for each download and injects correct metadata (Name, Vendor, Version) and install commands.
- **Intune-Ready Preparation:** Converts generated PSADT packages into descriptive `.intunewin` files (e.g., `Google_Chrome_121.0.6167.140_x64.intunewin`).
- **Resilient Execution:** Built-in retry logic with exponential backoff for network-related failures.
- **Full Traceability:** Centralized CSV logging of all discovery, download, packaging, and conversion activities.

## 📋 Prerequisites

- **OS:** Windows 10/11 or Windows Server 2016+ (Required for `IntuneWinAppUtil.exe`).
- **PowerShell:** Windows PowerShell 5.1 or PowerShell Core 7.x.
- **Evergreen Module:** Install via PowerShell:
  ```powershell
  Install-Module Evergreen -Scope CurrentUser
  ```
- **Microsoft Win32 Content Prep Tool:** Download `IntuneWinAppUtil.exe` from [Microsoft's GitHub](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool) and place it in the `Tools\` folder of this project.

## 🛠️ Setup & Configuration

### 1. Configure the Application Manifest (`EvergreenLibrary.json`)
Define the applications, vendors, and filters for the versions you want to track.
```json
{
  "Applications": [
    {
      "Name": "GoogleChrome",
      "Vendor": "Google",
      "EvergreenApp": "GoogleChrome",
      "Filter": "$_.Channel -eq 'Stable' -and $_.Architecture -eq 'x64' -and $_.Type -eq 'msi'"
    }
  ]
}
```

### 2. PSADT Template
Ensure a valid PSADT toolkit structure exists in `PsApps\Temp`. The script uses this as the base template for every new package created.

## 🆕 Adding New Applications

Easily add new applications to your library using the automated onboarding tools. For detailed instructions, see the **[Application Onboarding Guide](docs/ONBOARDING.md)**.

### Quick Start:
1. **Find App:** `.\Scripts\Find-EvergreenLibraryApp.ps1 -Name "AppName"`
2. **Test Filter:** `.\Scripts\Test-EvergreenLibraryFilter.ps1 -EvergreenApp "FullName"`
3. **Register:** `.\Scripts\Add-EvergreenLibraryApp.ps1 -Name "..." -Vendor "..." -EvergreenApp "..." -Filter "..."`

## 📖 Usage

Run the main synchronization script from an elevated PowerShell prompt:

```powershell
# Sync all applications defined in the manifest
.\Invoke-EvergreenLibrarySync.ps1 -LibraryPath "C:\Evergreen"

# Sync a specific application only
.\Invoke-EvergreenLibrarySync.ps1 -AppName "7Zip" -Verbose

# Specify custom config and log locations
.\Invoke-EvergreenLibrarySync.ps1 -ConfigFile "MyApps.json" -LogFile "Sync.csv"
```

### System Architecture
For a visual overview of how the pipeline, manifests, and deployment configurations interact, see the **[System Workflow Diagram](docs/WORKFLOW_DIAGRAM.md)**.

### Script Parameters
- `-LibraryPath`: The root directory for your application repository (Default: `C:\Evergreen`).
- `-ConfigFile`: Path to your JSON manifest (Default: `EvergreenLibrary.json`).
- `-LogFile`: Path to the CSV log file (Default: `EvergreenSyncLog.csv`).
- `-AppName`: (Optional) Limit the sync to a single application by name.
- `-StopAtPhase`: (Optional) Stop the pipeline after a specific phase. Valid values: `Download`, `PSADT`, `IntuneWin` (Default).

## 📁 Project Structure

- `Invoke-EvergreenLibrarySync.ps1`: The primary entry point orchestrating the entire pipeline.
- `Scripts\`:
    - `LibraryFunctions.ps1`: Discovery and retrieval logic.
    - `PSADTFunctions.ps1`: PSADT packaging and metadata injection.
    - `IntuneWinFunctions.ps1`: IntuneWin conversion logic.
    - `Find-EvergreenLibraryApp.ps1`: Search for Evergreen applications.
    - `Test-EvergreenLibraryFilter.ps1`: Interactively test filters.
    - `Add-EvergreenLibraryApp.ps1`: Automatically update manifest.
- `Installers\`: Dedicated directory for raw application downloads.
- `Packages\`: Output directory for generated PSADT packages.
- `Packages\IntuneWin\`: Output directory for final `.intunewin` files.
- `Tools\`: Recommended location for `IntuneWinAppUtil.exe`.
- `PsApps\Temp\`: Source directory for the PSADT base template.

## 📝 Logging & Monitoring

All activities are recorded in `EvergreenSyncLog.csv`. This log includes:
- **Timestamp:** When the action occurred.
- **AppName:** The name of the application processed.
- **Status:** Success, Skipped (if already up to date), or Error.
- **Message:** Detailed outcome, including generated package names or error details.
- **Path:** Full path to the retrieved installer or generated package.

## ⚖️ License
This project is provided "as-is" for automation research and foundation. Always test generated packages in a lab environment before deploying to production.
