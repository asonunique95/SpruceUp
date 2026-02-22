# Evergreen Library Automation: System Workflow

This diagram visualizes the end-to-end automation flow, specifically highlighting how the `DeploymentConfig.json` and the dynamic `{InstallerName}` placeholder are integrated into the pipeline.

```mermaid
graph TD
    subgraph "1. Discovery Phase"
        A[EvergreenLibrary.json] -->|Tracks Apps| B(Invoke-EvergreenLibrarySync.ps1)
        C[Evergreen PowerShell Module] <-->|Check Latest Version| B
    end

    subgraph "2. Download Phase"
        B -->|If New Version Found| D[Download Installer]
        D -->|Save to| E[/Installers Folder/]
    end

    subgraph "3. Configuration Phase"
        F[(DeploymentConfig.json)] -.->|Read Custom Commands| B
        B -->|Inject Metadata| G{Placeholder Logic}
        E -->|Get Filename| G
        G -->|Replace {InstallerName}| H[Final PSADT Script]
    end

    subgraph "4. Packaging Phase"
        H -->|Inject into| I[Invoke-AppDeployToolkit.ps1]
        J[PsApps/Temp Template] -->|Copy to| K[/Packages Folder/]
        I -->|Placed in| K
        E -->|Staged in| K
    end

    subgraph "5. Final Delivery"
        K -->|Convert via IntuneWinAppUtil| L([.intunewin File])
        L -->|Ready for| M[Microsoft Intune]
    end

    style F fill:#f9f,stroke:#333,stroke-width:2px
    style G fill:#bbf,stroke:#333,stroke-width:2px
    style L fill:#dfd,stroke:#333,stroke-width:2px
```

### Workflow Highlights:

- **1. Discovery:** The pipeline uses `EvergreenLibrary.json` to define which apps to track. It queries the `Evergreen` PowerShell module to determine if a newer version is available on the vendor's site.
- **2. Configuration Lookup:** `Invoke-EvergreenLibrarySync.ps1` matches the application `Name` to an entry in `DeploymentConfig.json`.
- **3. Dynamic Placeholder Injection:** The script retrieves the actual filename of the downloaded installer and replaces the `{InstallerName}` placeholder within your `InstallCommand`.
- **4. PSADT Wrapping:** The final command is injected into the `Invoke-AppDeployToolkit.ps1` script, and the installer is staged alongside it in a new package folder.
- **5. IntuneWin Conversion:** The entire PSADT package is converted into a `.intunewin` file, ready for upload to Microsoft Intune.
