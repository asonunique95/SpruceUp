# 🌲 SpruceUp

**Automated Evergreen App Lifecycle Management & Intune Preparation.**

SpruceUp is a robust PowerShell-based pipeline designed to take the "mess" out of enterprise application management. It automatically scouts for fresh versions of your favorite apps using the [Evergreen](https://github.com/steve0hun/Evergreen) module, "spruces them up" by wrapping them in the industry-standard [PSAppDeployToolkit (PSADT)](https://psappdeploytoolkit.com/), and prepares them for immediate deployment via Microsoft Intune.

Whether you're tracking hundreds of public apps or sideloading your own internal tools, SpruceUp ensures your repository stays fresh, organized, and ready for action.

## 🚀 Key Features

- **Automated Discovery:** Continuously monitors for new application versions using the `Evergreen` module. See the **[Full List of Supported Apps](docs/SUPPORTED_APPS.md)**.
- **Smart Sync:** Only downloads new or missing installers, saving bandwidth and storage.
- **Manual Sideloading:** Easily wrap local installers (not tracked by Evergreen) into the automated PSADT/IntuneWin pipeline.
- **External Storage Support:** Redirect high-volume data (Installers, Packages) to external drives or SMB shares while keeping config files local.
- **Structured Organization:** Organizes installers into a clean `Installers\<Publisher>\<Application>\<Channel>\<Version>\<Architecture>` hierarchy.
- **Automated PSADT Wrapping:** Automatically stages a PSADT template for each download and injects correct metadata (Name, Vendor, Version) and install commands.
- **Intune-Ready Preparation:** Converts generated PSADT packages into descriptive `.intunewin` files (e.g., `Google_GoogleChrome_121.0.6167.140_x64.intunewin`).
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
.\Invoke-EvergreenLibrarySync.ps1 -ConfigFile "MyApps.json" -TextLog "MyLog.log" -SummaryLog "MySummary.csv"

# Sync to an external drive or SMB share
.\Invoke-EvergreenLibrarySync.ps1 -DataPath "X:\EvergreenData"
```

### Sideloading Local Packages
For apps not tracked by Evergreen (e.g. internal LOB apps), use the local sync script:

```powershell
.\Invoke-LocalPackageSync.ps1 -AppName "MyCustomApp" `
                             -Vendor "InternalIT" `
                             -Version "2.1.0" `
                             -SourcePath "C:\Downloads\setup.exe"
```

### System Architecture
For a visual overview of how the pipeline, manifests, and deployment configurations interact, see the **[System Workflow Diagram](docs/WORKFLOW_DIAGRAM.md)**.

### Script Parameters
- `-LibraryPath`: The directory containing your configuration files (Default: `C:\Evergreen`).
- `-DataPath`: The root directory for storing heavy data (Installers and Packages).
- `-InstallersPath`: (Optional) Explicit override for the Installers directory.
- `-PackagesPath`: (Optional) Explicit override for the Packages directory.
- `-ConfigFile`: Path to your JSON manifest (Default: `EvergreenLibrary.json`).
- `-TextLog`: Path to the detailed text log (Default: `SpruceUp.log`).
- `-SummaryLog`: Path to the CSV summary log (Default: `SyncSummary.csv`).
- `-AppName`: (Optional) Limit the sync to a single application by name.
- `-StopAtPhase`: (Optional) Stop the pipeline after a specific phase. Valid values: `Download`, `PSADT`, `IntuneWin` (Default).

## 📁 Project Structure

- `Invoke-EvergreenLibrarySync.ps1`: The primary entry point for automated Evergreen apps.
- `Invoke-LocalPackageSync.ps1`: Entry point for manual sideloading of local installers.
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

All activities are recorded in two locations:

1.  **`SpruceUp.log`**: A detailed text log containing all operations, status messages, and errors.
2.  **`SyncSummary.csv`**: A structured summary of all processed applications, including:
    - **Timestamp:** When the action occurred.
    - **AppName:** The name of the application processed.
    - **Version:** The version of the application.
    - **Status:** Success, Skipped (if already up to date), or Error.
    - **Path:** Full path to the retrieved installer or generated package.
    - **Message:** Detailed outcome.

## ⚖️ License
This project is provided "as-is" for automation research and foundation. Always test generated packages in a lab environment before deploying to production.
