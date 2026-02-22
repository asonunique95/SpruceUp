# Initial Concept
A PowerShell-based automation tool utilizing the `Evergreen` module to fetch, organize, and manage latest enterprise application installers locally.

# Product Guide - Evergreen Library Automation

## Vision
The project aims to develop a PowerShell-based automation tool that leverages the `Evergreen` module to provide full lifecycle management of enterprise application installers. The tool will serve as a robust, automated repository for system administrators and DevOps engineers, ensuring they always have the latest, verified application installers organized and ready for deployment.

## Target Audience
- **System Administrators:** Responsible for maintaining software repositories for enterprise environments.
- **DevOps Engineers:** Focused on automating deployment pipelines and ensuring toolchains are up-to-date.

## Core Goals
- **Full Lifecycle Automation:** Automate everything from discovering new application versions to downloading, organizing, and cleaning up outdated installers.
- **Granular Pipeline Control:** Provide flexibility to stop the automation at specific stages (Download, PSADT, IntuneWin) based on immediate needs.
- **PoC Development:** Initially focus on a solid Proof of Concept (PoC) to demonstrate the automated flow before expanding into complex integrations.

## Key Features
- **Version Tracking:** Continuously monitor for new application versions and automatically initiate downloads.
- **Configurable Pipeline:** Use the `-StopAtPhase` parameter to control how far an application proceeds through the packaging and conversion flow.
- **Granular Deployment Customization:** Define application-specific installation and uninstallation commands, and specify processes to close, via `DeploymentConfig.json`.
- **Manual Application Sideloading:** Wrap local installers that are not tracked by the Evergreen module into the automated PSADT and IntuneWin pipeline.
- **External Storage Support:** Redirect high-volume data (Installers, Packages, and IntuneWin files) to external drives or SMB shares while keeping configuration and scripts local.
- **Streamlined Onboarding:** Specialized helper scripts, interactive filter testing, and documentation to simplify adding new applications to the library.
- **Multi-Publisher Support:** Comprehensive support for major publishers, including Microsoft, Google, Adobe, and others.
- **Storage Management:** Intelligent organization of installers into a dedicated `Installers/` subfolder and automatic cleanup of legacy versions to optimize local storage.

## Integration Strategy
- **Stage 1 (Completed):** Standalone automated flow for discovery, download, and organization based on `EvergreenLibrary.json`.
- **Stage 2 (Completed):** Automate the creation of PowerShell App Deployment Toolkit (PSADT) packages by copying templates and installers and dynamically populating `Invoke-AppDeployToolkit.ps1`.
- **Stage 3 (Completed):** Convert generated PSADT packages into `.intunewin` files for automated Intune uploads.
- **Stage 4 (Future):** Implement automated upload to Microsoft Intune via Graph API.
