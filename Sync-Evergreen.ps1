$LibraryPath = "C:\Evergreen"
$ConfigFile = Join-Path $LibraryPath "EvergreenLibrary.json"
$LogFile = Join-Path $LibraryPath "EvergreenSyncLog.csv"

# 1. Check for Evergreen Module
if (-not (Get-Module -ListAvailable -Name "Evergreen")) {
    Write-Error "The 'Evergreen' module is not installed. Please run: Install-Module -Name Evergreen -Scope CurrentUser"
    return
}

if (-not (Get-Module -Name "Evergreen")) {
    Write-Host "Importing Evergreen module..." -ForegroundColor Gray
    Import-Module -Name "Evergreen"
}

# 2. Check for Configuration
if (-not (Test-Path $ConfigFile)) {
    Write-Error "Could not find EvergreenLibrary.json at $ConfigFile"
    return
}

# 3. Load the configuration
$Config = Get-Content $ConfigFile | ConvertFrom-Json
$Apps = $Config.Applications
$Total = $Apps.Count
$Index = 0
$Results = @()

Write-Host "`nStarting Evergreen Library Update for $Total applications..." -ForegroundColor Cyan

foreach ($App in $Apps) {
    $Index++
    
    Write-Progress -Activity "Evergreen Library Sync" `
                   -Status "Checking: $($App.Name) ($Index of $Total)" `
                   -PercentComplete (($Index / $Total) * 100)

    try {
        Write-Host "Syncing $($App.Name)... " -NoNewline -ForegroundColor White
        
        # Suppress internal module warnings
        $AppDetails = Get-EvergreenApp -Name $App.EvergreenApp -WarningAction SilentlyContinue
        
        $FilterScript = [scriptblock]::Create($App.Filter)
        
        # Filter, then sort by version descending and pick the latest one only
        $FilteredApp = $AppDetails | Where-Object {
            $inputObject = $_
            & $FilterScript
        } | Sort-Object Version -Descending | Select-Object -First 1

        if ($FilteredApp) {
            $AppFolder = Join-Path $LibraryPath $App.Name
            $SavedFiles = $FilteredApp | Save-EvergreenApp -Path $AppFolder -WarningAction SilentlyContinue
            
            if ($null -ne $SavedFiles) {
                Write-Host "Done (v$($FilteredApp.Version))." -ForegroundColor Green
                foreach ($File in $SavedFiles) {
                    $PathToLog = if ($File.Path) { $File.Path } else { $File.ToString() }
                    
                    if (Test-Path $PathToLog) {
                        $FileInfo = Get-Item $PathToLog
                        $FileName = $FileInfo.Name
                        $SizeMB = [math]::Round($FileInfo.Length / 1MB, 2)
                        
                        Write-Host "  -> Saved: $FileName ($($SizeMB)MB)" -ForegroundColor DarkGreen
                        
                        $Results += [PSCustomObject]@{
                            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                            AppName   = $App.Name
                            Status    = "Success"
                            FileName  = $FileName
                            SizeMB    = $SizeMB
                            Path      = $PathToLog
                            Message   = "v$($FilteredApp.Version) synced successfully"
                        }
                    }
                }
            } else {
                Write-Host "Up to date." -ForegroundColor Gray
                $Results += [PSCustomObject]@{
                    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    AppName   = $App.Name
                    Status    = "Skipped"
                    FileName  = "Existing"
                    SizeMB    = 0
                    Path      = "N/A"
                    Message   = "v$($FilteredApp.Version) is already up to date"
                }
            }
        } else {
            Write-Host "Filtered." -ForegroundColor Yellow
            $Results += [PSCustomObject]@{
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                AppName   = $App.Name
                Status    = "Warning"
                FileName  = "N/A"
                SizeMB    = 0
                Path      = "N/A"
                Message   = "No version found matching filter"
            }
        }
    }
    catch {
        Write-Host "Error!" -ForegroundColor Red
        Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
        $Results += [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            AppName   = $App.Name
            Status    = "Error"
            FileName  = "N/A"
            SizeMB    = 0
            Path      = "N/A"
            Message   = $_.Exception.Message
        }
    }
}

# Export results to CSV
if ($Results.Count -gt 0) {
    if (Test-Path $LogFile) {
        $Results | Export-Csv -Path $LogFile -Append -NoTypeInformation
    } else {
        $Results | Export-Csv -Path $LogFile -NoTypeInformation
    }
}

Write-Progress -Activity "Evergreen Library Sync" -Completed
Write-Host "`nSync Complete! Log saved to: $LogFile" -ForegroundColor Green
