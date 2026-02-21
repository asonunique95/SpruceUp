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

# 2. Setup Paths
$FullConfigPath = Join-Path $LibraryPath $ConfigFile
$FullLogPath = Join-Path $LibraryPath $LogFile

# 3. Load Manifest
try {
    $Apps = Get-EvergreenLibraryApps -Path $FullConfigPath
}
catch {
    Write-Error "Failed to load manifest: $($_.Exception.Message)"
    return
}

# 4. Filter by AppName if provided
if ($AppName) {
    $Apps = $Apps | Where-Object { $_.Name -eq $AppName }
    if (-not $Apps) {
        Write-Warning "No application named '$AppName' found in manifest."
        return
    }
}

# 5. Process Applications
Write-Host "Starting Evergreen Library Sync for $($Apps.Count) applications..." -ForegroundColor Cyan

foreach ($App in $Apps) {
    Write-Host "Processing $($App.Name)... " -NoNewline
    
    try {
        $SyncResult = Sync-EvergreenLibraryApp -AppConfig $App -LibraryPath $LibraryPath -Verbose:$VerbosePreference

        if ($null -ne $SyncResult) {
            if ($SyncResult.NewDownload) {
                Write-Host "New version (v$($SyncResult.Version)) downloaded." -ForegroundColor Green
                $Status = "Success"
                $Message = "New version downloaded"
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
