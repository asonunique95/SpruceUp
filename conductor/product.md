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
- **PoC Development:** Initially focus on a solid Proof of Concept (PoC) to demonstrate the automated flow before expanding into complex integrations.

## Key Features
- **Version Tracking:** Continuously monitor for new application versions and automatically initiate downloads.
- **Multi-Publisher Support:** Comprehensive support for major publishers, including Microsoft, Google, Adobe, and others.
- **Storage Management:** Intelligent organization of installers and automatic cleanup of legacy versions to optimize local storage.

## Integration Strategy
- **Stage 1 (Completed):** Standalone automated flow for discovery, download, and organization based on `EvergreenLibrary.json`.
- **Stage 2 (Current):** Automate the creation of PowerShell App Deployment Toolkit (PSADT) packages by copying templates and installers and dynamically populating `Invoke-AppDeployToolkit.ps1`.
- **Stage 3 (Future):** Convert generated PSADT packages into `.intunewin` files for automated Intune uploads.
