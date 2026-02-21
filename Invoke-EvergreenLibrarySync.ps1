[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$LibraryPath = "C:\Evergreen",

    [Parameter(Mandatory = $false)]
    [string]$ConfigFile = "EvergreenLibrary.json",

    [Parameter(Mandatory = $false)]
    [string]$LogFile = "EvergreenSyncLog.csv",

    [Parameter(Mandatory = $false)]
    [string]$AppName
)

# 1. Dependency Checks & Function Import
if (-not (Get-Module -ListAvailable -Name "Evergreen")) {
    Write-Error "The 'Evergreen' module is required. Please install it with 'Install-Module Evergreen'."
    return
}
if (-not (Get-Module -Name "Evergreen")) { Import-Module -Name "Evergreen" }

# Import the library functions
$ScriptPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. (Join-Path $ScriptPath "Scripts\LibraryFunctions.ps1")
. (Join-Path $ScriptPath "Scripts\PSADTFunctions.ps1")
. (Join-Path $ScriptPath "Scripts\IntuneWinFunctions.ps1")

# 2. Setup Paths
$FullConfigPath = Join-Path $LibraryPath $ConfigFile
$FullLogPath = Join-Path $LibraryPath $LogFile
$InstallersPath = Join-Path $LibraryPath "Installers"
$PackagesPath = Join-Path $LibraryPath "Packages"
$IntuneWinPath = Join-Path $PackagesPath "IntuneWin"

# 3. Ensure Directories Exist
foreach ($Path in @($InstallersPath, $PackagesPath, $IntuneWinPath)) {
    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

# 4. Load Manifest
try {
    $Apps = Get-EvergreenLibraryApps -Path $FullConfigPath
}
catch {
    Write-Error "Failed to load manifest: $($_.Exception.Message)"
    return
}

# 5. Filter by AppName if provided
if ($AppName) {
    $Apps = $Apps | Where-Object { $_.Name -eq $AppName }
    if (-not $Apps) {
        Write-Warning "No application named '$AppName' found in manifest."
        return
    }
}

# 6. Process Applications
Write-Host "Starting Evergreen Library Sync for $($Apps.Count) applications..." -ForegroundColor Cyan

foreach ($App in $Apps) {
    Write-Host "Processing $($App.Name)... " -NoNewline
    
    try {
        $SyncResult = Sync-EvergreenLibraryApp -AppConfig $App -LibraryPath $LibraryPath -Verbose:$VerbosePreference

        if ($null -ne $SyncResult) {
            if ($SyncResult.NewDownload) {
                Write-Host "New version (v$($SyncResult.Version)) downloaded." -ForegroundColor Green
                
                # --- PSADT PACKAGING ---
                Write-Host "  -> Creating PSADT package... " -NoNewline
                try {
                    $PackageName = Get-PSADTPackageName -Vendor $App.Vendor -AppName $App.Name -Version $SyncResult.Version -Arch $SyncResult.Architecture
                    $PackageFolder = Join-Path $PackagesPath $PackageName
                    
                    Copy-PSADTTemplate -DestinationPath $PackageFolder -Verbose:$VerbosePreference | Out-Null
                    Stage-PSADTInstaller -InstallerPath $SyncResult.Path -DestinationPackagePath $PackageFolder -Verbose:$VerbosePreference | Out-Null
                    Set-PSADTAppHeader -PackagePath $PackageFolder -Vendor $App.Vendor -AppName $App.Name -Version $SyncResult.Version -Arch $SyncResult.Architecture -Verbose:$VerbosePreference | Out-Null
                    Set-PSADTInstallCommand -PackagePath $PackageFolder -InstallerName (Split-Path $SyncResult.Path -Leaf) -Verbose:$VerbosePreference | Out-Null
                    
                    Write-Host "Done." -ForegroundColor DarkGreen

                    # --- INTUNEWIN CONVERSION ---
                    Write-Host "  -> Converting to .intunewin... " -NoNewline
                    try {
                        $IntuneWinFile = New-IntuneWinPackage -SourceFolder $PackageFolder `
                                                             -SetupFile "Invoke-AppDeployToolkit.exe" `
                                                             -OutputFolder $IntuneWinPath `
                                                             -OutputFileName $PackageName `
                                                             -Verbose:$VerbosePreference
                        
                        if ($IntuneWinFile) {
                            Write-Host "Done." -ForegroundColor DarkGreen
                            $Status = "Success"
                            $Message = "New version downloaded, PSADT package created, and converted to .intunewin: $(Split-Path $IntuneWinFile -Leaf)"
                        } else {
                            Write-Host "Failed (Tool Error)!" -ForegroundColor Red
                            $Status = "Partial Success"
                            $Message = "New version downloaded and PSADT created, but .intunewin conversion failed."
                        }
                    }
                    catch {
                        Write-Host "Failed!" -ForegroundColor Red
                        Write-Host "     -> $($_.Exception.Message)" -ForegroundColor Red
                        $Status = "Partial Success"
                        $Message = "New version downloaded and PSADT created, but .intunewin conversion errored: $($_.Exception.Message)"
                    }
                    # ----------------------------
                }
                catch {
                    Write-Host "Failed!" -ForegroundColor Red
                    Write-Host "     -> $($_.Exception.Message)" -ForegroundColor Red
                    $Status = "Partial Success"
                    $Message = "New version downloaded but PSADT packaging failed: $($_.Exception.Message)"
                }
                # -----------------------
            }
            else {
                Write-Host "Up to date (v$($SyncResult.Version))." -ForegroundColor Gray
                $Status = "Skipped"
                $Message = "Already up to date"
            }

            # Log results
            $FileInfo = Get-Item -Path $SyncResult.Path
            Write-EvergreenSyncLog -AppName $App.Name `
                                   -Status $Status `
                                   -Message $Message `
                                   -LogFile $FullLogPath `
                                   -FileName $FileInfo.Name `
                                   -SizeMB ([math]::Round($FileInfo.Length/1MB, 2)) `
                                   -Path $SyncResult.Path
        }
        else {
            Write-Host "Skipped (no matching version found)." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error!" -ForegroundColor Red
        Write-Host "  -> $($_.Exception.Message)" -ForegroundColor Red
        
        Write-EvergreenSyncLog -AppName $App.Name `
                               -Status "Error" `
                               -Message $_.Exception.Message `
                               -LogFile $FullLogPath
    }
}

Write-Host "Sync Complete!" -ForegroundColor Green
