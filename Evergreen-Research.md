# Evergreen Module Research & Automation Strategy

## Goals
The primary goal is to use the `Evergreen` PowerShell module to fetch the latest installer files for common enterprise applications. These installers must be saved locally in a structured and organized manner, categorized by:
- **Publisher** (e.g., Microsoft, Google, Adobe)
- **Application Name**
- **Version**
- **Architecture/Channel**

This research serves as the foundation for a separate project where these capabilities will be integrated into automated deployment and maintenance flows.

## Current Progress
- [x] Researched module manifest and public functions (`Find-EvergreenApp`, `Get-EvergreenApp`, `Save-EvergreenApp`, `New-EvergreenLibrary`).
- [x] Executed `Update-Evergreen` to sync the latest application manifests and support scripts to the local cache.

---

## Technical Strategy

### 1. Discovery & Metadata
Use `Find-EvergreenApp` to identify supported applications and `Get-EvergreenApp` to retrieve the most recent metadata.
```powershell
# Search for an application
Find-EvergreenApp -Name "Chrome"

# Get metadata for a specific app
$App = Get-EvergreenApp -Name "GoogleChrome"
```

### 2. Standardized Downloads
The `Save-EvergreenApp` function automatically builds a hierarchical directory structure based on the application's properties (Channel, Version, Architecture). 
To enforce a **Publisher\Application** root, prefix the `-Path` parameter:
```powershell
$PublisherPath = "C:\Apps\Google"
Get-EvergreenApp -Name "GoogleChrome" | Save-EvergreenApp -Path $PublisherPath
```
*Resulting structure: `C:\Apps\Google\GoogleChrome\Stable\121.0.6167.140\x64\googlechromestandaloneenterprise64.msi`*

### 3. Automated Library Management (Scaling)
For managing multiple applications across different publishers, the **Library** feature is the most efficient approach.

#### Step A: Initialize the Library
```powershell
New-EvergreenLibrary -Path "C:\InstallerRepo" -Name "EnterpriseLibrary"
```

#### Step B: Configure the Manifest (`EvergreenLibrary.json`)
Organize by publisher by modifying the `Name` property in the library configuration:
```json
{
    "Applications": [
        {
            "Name": "Microsoft\Edge",
            "EvergreenApp": "MicrosoftEdge",
            "Filter": "$_.Channel -eq 'Stable' -and $_.Architecture -eq 'x64'"
        },
        {
            "Name": "Adobe\Reader",
            "EvergreenApp": "AdobeAcrobatReaderDC",
            "Filter": "$_.Language -eq 'English'"
        }
    ]
}
```

#### Step C: Scheduled Sync
Run the library update to process all defined applications in one flow:
```powershell
Start-EvergreenLibraryUpdate -Path "C:\InstallerRepo"
```

---

## Next Steps
- Transfer this documentation to the automation project.
- Define the list of enterprise applications to be tracked.
- Implement the JSON library configuration to reflect the desired Publisher\Application hierarchy.
- Script the `Start-EvergreenLibraryUpdate` process as a recurring task.
