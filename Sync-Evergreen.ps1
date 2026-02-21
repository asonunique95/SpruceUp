$LibraryPath = "C:\Evergreen"
$ConfigFile = Join-Path $LibraryPath "EvergreenLibrary.json"
$LogFile = Join-Path $LibraryPath "EvergreenSyncLog.csv"

# Check if the config file exists
if (-not (Test-Path $ConfigFile)) {
    Write-Error "Could not find EvergreenLibrary.json at $ConfigFile"
    return
}

# Load the configuration
$Config = Get-Content $ConfigFile | ConvertFrom-Json
$Apps = $Config.Applications
$Total = $Apps.Count
$Index = 0
$Results = @()

Write-Host "`nStarting Evergreen Library Update for $Total applications..." -ForegroundColor Cyan

foreach ($App in $Apps) {
    $Index++
    $Processed = $false
    
    Write-Progress -Activity "Evergreen Library Sync" `
                   -Status "Checking: $($App.Name) ($Index of $Total)" `
                   -PercentComplete (($Index / $Total) * 100)

    try {
        $AppDetails = Get-EvergreenApp -Name $App.EvergreenApp
        $FilterScript = [scriptblock]::Create($App.Filter)
        $FilteredApp = $AppDetails | Where-Object {
            $inputObject = $_
            & $FilterScript
        }

        if ($FilteredApp) {
            $AppRoot = Join-Path $LibraryPath "Apps"
            
            # Save-EvergreenApp execution
            $SavedFiles = $FilteredApp | Save-EvergreenApp -Path $AppRoot
            
            if ($null -ne $SavedFiles) {
                $Processed = $true
                foreach ($File in $SavedFiles) {
                    # Handle both strings and objects returned by the module
                    $PathToLog = if ($File.Path) { $File.Path } else { $File.ToString() }
                    
                    if (Test-Path $PathToLog) {
                        $FileInfo = Get-Item $PathToLog
                        $FileName = $FileInfo.Name
                        $SizeMB = [math]::Round($FileInfo.Length / 1MB, 2)
                        
                        Write-Host "[OK] $($App.Name) ($FileName) - $($SizeMB)MB" -ForegroundColor Green
                        
                        $Results += [PSCustomObject]@{
                            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                            AppName   = $App.Name
                            Status    = "Success"
                            FileName  = $FileName
                            SizeMB    = $SizeMB
                            Path      = $PathToLog
                            Message   = "File synced successfully"
                        }
                    }
                }
            } else {
                # If SavedFiles is null, it usually means UNCHANGED
                Write-Host "[-] $($App.Name) is already up to date." -ForegroundColor Gray
                $Results += [PSCustomObject]@{
                    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    AppName   = $App.Name
                    Status    = "Skipped"
                    FileName  = "Existing"
                    SizeMB    = 0
                    Path      = "N/A"
                    Message   = "File is already up to date"
                }
                $Processed = $true
            }
        } else {
            Write-Warning "No version found for $($App.Name) matching filter."
            $Results += [PSCustomObject]@{
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                AppName   = $App.Name
                Status    = "Warning"
                FileName  = "N/A"
                SizeMB    = 0
                Path      = "N/A"
                Message   = "No version found matching filter"
            }
            $Processed = $true
        }
    }
    catch {
        Write-Host "[ERROR] Failed to update $($App.Name): $($_.Exception.Message)" -ForegroundColor Red
        $Results += [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            AppName   = $App.Name
            Status    = "Error"
            FileName  = "N/A"
            SizeMB    = 0
            Path      = "N/A"
            Message   = $_.Exception.Message
        }
        $Processed = $true
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
