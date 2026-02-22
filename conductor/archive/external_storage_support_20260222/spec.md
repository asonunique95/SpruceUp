# Specification - External Storage Support

This track adds the ability to redirect the download and conversion output of the Evergreen Library to an external storage location, such as an SMB file share, while keeping the default local configuration.

## 🎯 Goal
Allow users to specify a separate root directory for "heavy" data (Installers, Packages, and IntuneWin files) while keeping the scripts and configuration files local.

## 🛠️ Key Features
1. **New Parameter:** Add a `-DataPath` parameter to `Invoke-EvergreenLibrarySync.ps1` and `Invoke-LocalPackageSync.ps1`.
2. **Path Logic Update:** Decouple `$LibraryPath` (which contains configuration files) from the storage location for downloads and packages.
3. **SMB/UNC Path Support:** Ensure the script can correctly handle UNC paths (e.g., `\Server\Share\EvergreenData`).
4. **Maintain Defaults:** If `-DataPath` is not provided, it should default to the current `$LibraryPath`.

## 📋 Success Criteria
- Running the sync with `-DataPath "\Server\Share\EvergreenData"` downloads the installers to the remote share.
- The local `EvergreenLibrary.json` and `DeploymentConfig.json` are still used for configuration.
- The `.intunewin` files are correctly generated on the remote share.
