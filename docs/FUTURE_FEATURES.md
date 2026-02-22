# Future Features & Roadmap

This document tracks planned features and architectural improvements for the Evergreen Library Automation project.

## 🚀 Planned Features

### 1. Manual Application Import (Sideloading)
- **Description:** Allow users to wrap local installers (not sourced from Evergreen) into the pipeline.
- **Why:** Useful for internal line-of-business (LOB) apps or specific versions not tracked by Evergreen.
- **Proposed Logic:**
    - Skip Discovery and Download phases.
    - Accept a `-SourcePath` to a local file.
    - Accept manual `-AppName`, `-Vendor`, and `-Version` parameters.
    - Proceed with PSADT injection using `DeploymentConfig.json` and final IntuneWin conversion.
- **Branch Name:** `feature/manual-import`

---

## 🛠️ Technical Debt & Improvements
- [ ] Implement MSI ProductCode lookup for the `{ProductCode}` placeholder.
- [ ] Add support for "Dependencies" in `DeploymentConfig.json`.
