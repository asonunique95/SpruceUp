# Tech Stack - Evergreen Library Automation

## Core Technologies
- **PowerShell:** The primary automation and scripting language.
- **Evergreen Module:** Powers the automated discovery and download of enterprise application installers.
- **PowerShell App Deployment Toolkit (PSADT):** The standard framework for creating robust application deployment packages.

## Integration & Platform
- **Microsoft Intune:** The ultimate target platform for automated application deployment.
- **IntuneWinAppUtil:** (Future) For converting PSADT packages into `.intunewin` files.

## Data & Configuration
- **JSON:** Used for the library manifest (`EvergreenLibrary.json`) and project metadata.
- **CSV:** (Secondary) Used for supplementary application lists and logging.

## Workflow Tools
- **Conductor:** For project management and task orchestration.
- **Git:** For version control and tracking changes.
