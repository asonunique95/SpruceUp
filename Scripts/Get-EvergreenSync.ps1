param(
    [Parameter(Mandatory=$true)]
    [string]$EvergreenApp,
    
    [Parameter(Mandatory=$true)]
    [string]$Filter,
    
    [Parameter(Mandatory=$true)]
    [string]$LibraryPath,

    [Parameter(Mandatory=$true)]
    [string]$AppName
)

try {
    $AppDetails = Get-EvergreenApp -Name $EvergreenApp -WarningAction SilentlyContinue
    $FilterScript = [scriptblock]::Create($Filter)
    
    $FilteredApp = $AppDetails | Where-Object {
        $inputObject = $_
        & $FilterScript
    } | Sort-Object Version -Descending | Select-Object -First 1

    if ($FilteredApp) {
        # Use the custom AppName from JSON for the folder structure
        $AppFolder = Join-Path $LibraryPath $AppName
        
        $SavedFiles = $FilteredApp | Save-EvergreenApp -Path $AppFolder -WarningAction SilentlyContinue
        
        if ($null -ne $SavedFiles) {
            $Path = if ($SavedFiles[0].Path) { $SavedFiles[0].Path } else { $SavedFiles[0].ToString() }
            
            return [PSCustomObject]@{
                Version      = $FilteredApp.Version
                Architecture = $FilteredApp.Architecture
                Path         = $Path
                NewDownload  = $true
            }
        } else {
            return [PSCustomObject]@{
                Version      = $FilteredApp.Version
                Architecture = $FilteredApp.Architecture
                Path         = "Existing"
                NewDownload  = $false
            }
        }
    }
}
catch {
    throw "Download Failed: $($_.Exception.Message)"
}
return $null
