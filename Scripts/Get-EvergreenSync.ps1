param(
    [Parameter(Mandatory=$false)]
    [string]$EvergreenApp,
    
    [Parameter(Mandatory=$false)]
    [string]$Filter,
    
    [Parameter(Mandatory=$false)]
    [string]$LibraryPath,

    [Parameter(Mandatory=$false)]
    [string]$AppName,

    [Parameter(Mandatory=$false)]
    [switch]$ListAll,

    [Parameter(Mandatory=$false)]
    [switch]$ListAvailable
)

# Determine the root path and config file location
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$ConfigFile = Join-Path $RootDir "EvergreenLibrary.json"

# 1. Show apps defined in your local EvergreenLibrary.json
if ($ListAvailable) {
    if (Test-Path $ConfigFile) {
        $Config = Get-Content $ConfigFile | ConvertFrom-Json
        Write-Host "`nApps defined in your library ($ConfigFile):" -ForegroundColor Cyan
        $Config.Applications | Select-Object Name, Vendor, EvergreenApp | Format-Table -AutoSize
    } else {
        Write-Error "Could not find library file at $ConfigFile"
    }
    return
}

# 2. Show every app supported by the module globally
if ($ListAll) {
    Find-EvergreenApp
    return
}

# 3. Sync Mode: Requires parameters
if (-not $EvergreenApp -or -not $Filter) {
    Write-Error "Please specify -EvergreenApp and -Filter, or use -ListAvailable / -ListAll"
    return
}

try {
    $AppDetails = Get-EvergreenApp -Name $EvergreenApp -WarningAction SilentlyContinue
    $FilterScript = [scriptblock]::Create($Filter)
    
    $FilteredApp = $AppDetails | Where-Object {
        $inputObject = $_
        & $FilterScript
    } | Sort-Object Version -Descending | Select-Object -First 1

    if ($FilteredApp) {
        $Folder = if ($AppName) { $AppName } else { $EvergreenApp }
        $AppFolder = Join-Path $LibraryPath $Folder
        
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
