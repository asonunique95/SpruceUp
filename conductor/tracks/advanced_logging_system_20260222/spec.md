# Specification - Advanced Logging System

This track overhauls the project's logging mechanism to provide a more professional and detailed audit trail. It replaces the basic CSV-only logging with a dual-stream system: a detailed `.log` file for all pipeline events and a separate `.csv` file for high-level sync summaries.

## 🎯 Goal
Provide comprehensive traceability for every step of the automation pipeline while maintaining a quick-look summary of application updates.

## 🛠️ Key Features
1. **Unified Logging Helper:** Create/Refactor a core function `Write-SpruceLog` that handles multiple output streams.
2. **Detailed Pipeline Log (`SpruceUp.log`):**
    - Capture all events: initialization, discovery, downloads, PSADT staging, IntuneWin conversion, and errors.
    - Standard log format: `[YYYY-MM-DD HH:MM:SS] [LEVEL] [App] Message`.
3. **Sync Summary Report (`SyncSummary.csv`):**
    - Maintain a row-per-app summary similar to the existing CSV.
    - Fields: Timestamp, AppName, Version, Status (Success/Skipped/Error), FinalPath.
4. **Verbosity Control:** Integration with PowerShell's `-Verbose` and `-Debug` streams.

## 📋 Success Criteria
- Running a sync results in a detailed text log showing every step taken for each application.
- A summary CSV is updated only when an application is actually processed or errors out.
- Errors are clearly logged in both files with stack traces (where available).

## 🚫 Out of Scope
- Logging to external databases or cloud monitoring services (e.g., Azure Monitor).
- Real-time dashboard generation.
