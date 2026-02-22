[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$LibraryPath = "C:\Evergreen",

    [Parameter(Mandatory = $false)]
    [string]$DataPath,

    [Parameter(Mandatory = $false)]
    [string]$InstallersPath,

    [Parameter(Mandatory = $false)]
    [string]$PackagesPath,

    [Parameter(Mandatory = $false)]
    [string]$ConfigFile = "EvergreenLibrary.json",

    [Parameter(Mandatory = $false)]
    [string]$DeployConfigFile = "DeploymentConfig.json",

    [Parameter(Mandatory = $false)]
    [string]$TextLog = "SpruceUp.log",

    [Parameter(Mandatory = $false)]
    [string]$SummaryLog = "SyncSummary.csv",

    [Parameter(Mandatory = $false)]
    [string]$AppName,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Download", "PSADT", "IntuneWin")]
    [string]$StopAtPhase = "IntuneWin"
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
# Root config and log files always stay in the local LibraryPath
$FullConfigPath = Join-Path $LibraryPath $ConfigFile
$FullDeployConfigPath = Join-Path $LibraryPath $DeployConfigFile
$FullTextLogPath = Join-Path $LibraryPath $TextLog
$FullSummaryLogPath = Join-Path $LibraryPath $SummaryLog

# Heavy data locations: Order of precedence is: 
# 1. Specific param (-InstallersPath / -PackagesPath)
# 2. General data param (-DataPath)
# 3. Default (LibraryPath)

$FinalInstallersPath = if ($InstallersPath) { $InstallersPath } elseif ($DataPath) { Join-Path $DataPath "Installers" } else { Join-Path $LibraryPath "Installers" }
$FinalPackagesPath = if ($PackagesPath) { $PackagesPath } elseif ($DataPath) { Join-Path $DataPath "Packages" } else { Join-Path $LibraryPath "Packages" }
$FinalIntuneWinPath = Join-Path $FinalPackagesPath "IntuneWin"

# 3. Ensure Directories Exist
foreach ($Path in @($FinalInstallersPath, $FinalPackagesPath, $FinalIntuneWinPath)) {
    if (-not (Test-Path -Path $Path)) {
        try {
            Write-Verbose "Creating directory: $Path"
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
        }
        catch {
            Write-Error "Failed to create directory at '$Path'. If this is a network share, ensure you have provided the share name (e.g. \\homestor\Share) and have write permissions."
            return
        }
    }
}

# 4. Load Manifests
try {
    $Apps = Get-EvergreenLibraryApps -Path $FullConfigPath
    $DeployConfig = if (Test-Path $FullDeployConfigPath) { Get-Content -Path $FullDeployConfigPath -Raw | ConvertFrom-Json } else { $null }
}
catch {
    Write-Error "Failed to load manifests: $($_.Exception.Message)"
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
Write-SpruceLog -Message "Starting Evergreen Library Sync for $($Apps.Count) applications..." -Level "INFO" -LogFile $FullTextLogPath

foreach ($App in $Apps) {
    Write-SpruceLog -Message "Processing $($App.Name)..." -Level "INFO" -LogFile $FullTextLogPath
    
    try {
        $SyncResult = Sync-EvergreenLibraryApp -AppConfig $App -LibraryPath $LibraryPath -DataPath $FinalInstallersPath -Verbose:$VerbosePreference

        if ($null -ne $SyncResult) {
            if ($SyncResult.NewDownload) {
                Write-SpruceLog -Message "New version (v$($SyncResult.Version)) downloaded." -Level "INFO" -LogFile $FullTextLogPath
                
                $Status = "Success"
                $Message = "New version downloaded"

                if ($StopAtPhase -eq "Download") {
                    Write-SpruceLog -Message "  -> Stopping at Download phase as requested." -Level "INFO" -LogFile $FullTextLogPath
                }
                else {
                    # --- PSADT PACKAGING ---
                    Write-SpruceLog -Message "  -> Creating PSADT package..." -Level "INFO" -LogFile $FullTextLogPath
                    try {
                        $PackageName = Get-PSADTPackageName -Vendor $App.Vendor -AppName $App.Name -Version $SyncResult.Version -Arch $SyncResult.Architecture
                        $PackageFolder = Join-Path $FinalPackagesPath $PackageName
                        
                        # Get app-specific config
                        $AppDeploy = if ($DeployConfig -and $DeployConfig.$($App.Name)) { $DeployConfig.$($App.Name) } else { $null }
                        $ProcList = if ($AppDeploy -and $AppDeploy.ProcessesToClose) { $AppDeploy.ProcessesToClose } else { @() }
                        $CustomInstall = if ($AppDeploy -and $AppDeploy.InstallCommand) { $AppDeploy.InstallCommand } else { $null }
                        $CustomUninstall = if ($AppDeploy -and $AppDeploy.UninstallCommand) { $AppDeploy.UninstallCommand } else { $null }

                        Copy-PSADTTemplate -DestinationPath $PackageFolder -Verbose:$VerbosePreference | Out-Null
                        Stage-PSADTInstaller -InstallerPath $SyncResult.Path -DestinationPackagePath $PackageFolder -Verbose:$VerbosePreference | Out-Null
                        Set-PSADTAppHeader -PackagePath $PackageFolder -Vendor $App.Vendor -AppName $App.Name -Version $SyncResult.Version -Arch $SyncResult.Architecture -ProcessesToClose $ProcList -Verbose:$VerbosePreference | Out-Null
                        $InstallerFileName = Split-Path $SyncResult.Path -Leaf
                        Set-PSADTInstallCommand -PackagePath $PackageFolder -InstallerName $InstallerFileName -CustomCommand $CustomInstall -Verbose:$VerbosePreference | Out-Null
                        Set-PSADTUninstallCommand -PackagePath $PackageFolder -InstallerName $InstallerFileName -CustomCommand $CustomUninstall -Verbose:$VerbosePreference | Out-Null

                        Write-SpruceLog -Message "Done." -Level "INFO" -LogFile $FullTextLogPath
                        $Message = "New version downloaded and PSADT package created: $PackageName"

                        if ($StopAtPhase -eq "PSADT") {
                            Write-SpruceLog -Message "  -> Stopping at PSADT phase as requested." -Level "INFO" -LogFile $FullTextLogPath
                        }
                        else {
                            # --- INTUNEWIN CONVERSION ---
                            Write-SpruceLog -Message "  -> Converting to .intunewin..." -Level "INFO" -LogFile $FullTextLogPath
                            try {
                                $IntuneWinFile = New-IntuneWinPackage -SourceFolder $PackageFolder `
                                                                     -SetupFile "Invoke-AppDeployToolkit.exe" `
                                                                     -OutputFolder $FinalIntuneWinPath `
                                                                     -OutputFileName $PackageName `
                                                                     -Verbose:$VerbosePreference
                                
                                if ($IntuneWinFile) {
                                    Write-SpruceLog -Message "Done." -Level "INFO" -LogFile $FullTextLogPath
                                    $Message = "New version downloaded, PSADT package created, and converted to .intunewin: $(Split-Path $IntuneWinFile -Leaf)"
                                } else {
                                    Write-SpruceLog -Message "Failed (Tool Error)!" -Level "ERROR" -LogFile $FullTextLogPath
                                    $Status = "Partial Success"
                                    $Message = "New version downloaded and PSADT created, but .intunewin conversion failed."
                                }
                            }
                            catch {
                                Write-SpruceLog -Message "Failed!" -Level "ERROR" -LogFile $FullTextLogPath
                                Write-SpruceLog -Message "     -> $($_.Exception.Message)" -Level "ERROR" -LogFile $FullTextLogPath
                                $Status = "Partial Success"
                                $Message = "New version downloaded and PSADT created, but .intunewin conversion errored: $($_.Exception.Message)"
                            }
                            # ----------------------------
                        }
                    }
                    catch {
                        Write-SpruceLog -Message "Failed!" -Level "ERROR" -LogFile $FullTextLogPath
                        Write-SpruceLog -Message "     -> $($_.Exception.Message)" -Level "ERROR" -LogFile $FullTextLogPath
                        $Status = "Partial Success"
                        $Message = "New version downloaded but PSADT packaging failed: $($_.Exception.Message)"
                    }
                    # -----------------------
                }
            }
            else {
                Write-SpruceLog -Message "Up to date (v$($SyncResult.Version))." -Level "INFO" -LogFile $FullTextLogPath
                $Status = "Skipped"
                $Message = "Already up to date"
            }

            # Log results
            Write-SpruceLog -Message $Message -Level "INFO" -LogFile $FullTextLogPath -CsvFile $FullSummaryLogPath -Summary @{
                AppName = $App.Name
                Version = $SyncResult.Version
                Status  = $Status
                Path    = $SyncResult.Path
            }
        }
        else {
            Write-SpruceLog -Message "Skipped (no matching version found)." -Level "WARNING" -LogFile $FullTextLogPath
        }
    }
    catch {
        Write-SpruceLog -Message "Error! $($_.Exception.Message)" -Level "ERROR" -LogFile $FullTextLogPath
        
        Write-SpruceLog -Message $_.Exception.Message -Level "ERROR" -LogFile $FullTextLogPath -CsvFile $FullSummaryLogPath -Summary @{
            AppName = $App.Name
            Version = $null
            Status  = "Error"
            Path    = $null
        }
    }
}

Write-SpruceLog -Message "Sync Complete!" -Level "INFO" -LogFile $FullTextLogPath
