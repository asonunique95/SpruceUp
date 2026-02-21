function Get-EvergreenLibraryApps {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -Path $Path)) {
        throw "The manifest file at '$Path' does not exist."
    }

    $JsonContent = Get-Content -Path $Path -Raw | ConvertFrom-Json
    
    # Return the applications array
    return $JsonContent.Applications
}

function Get-LatestEvergreenAppVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$AppConfig
    )

    $EvergreenApp = $AppConfig.EvergreenApp
    $Filter = $AppConfig.Filter

    Write-Verbose "Fetching Evergreen metadata for '$EvergreenApp'..."
    $Metadata = Get-EvergreenApp -Name $EvergreenApp

    if ($Filter) {
        Write-Verbose "Applying filter: $Filter"
        $Metadata = $Metadata | Where-Object { Invoke-Expression -Command $Filter }
    }

    # Sort by version and return the latest one
    # Note: Evergreen objects usually have a 'Version' property. 
    # Sorting as a version type is more reliable if possible.
    $Latest = $Metadata | Sort-Object { [version]$_.Version } -Descending | Select-Object -First 1

    return $Latest
}

function Sync-EvergreenLibraryApp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$AppConfig,
        [Parameter(Mandatory = $true)]
        [string]$LibraryPath
    )

    $AppName = $AppConfig.Name
    $Publisher = $AppConfig.Vendor
    $EvergreenApp = $AppConfig.EvergreenApp
    
    # 1. Get latest version info
    $Latest = Get-LatestEvergreenAppVersion -AppConfig $AppConfig
    if (-not $Latest) {
        Write-Warning "No metadata found for '$AppName' with the given filters."
        return $null
    }

    # 2. Build target path
    # Expected structure: <RootPath>\<Publisher>\<Application>\<Channel>\<Version>\<Architecture>\
    $TargetFolder = Join-Path $LibraryPath $Publisher
    $TargetFolder = Join-Path $TargetFolder $AppName
    if ($Latest.Channel) { $TargetFolder = Join-Path $TargetFolder $Latest.Channel }
    $TargetFolder = Join-Path $TargetFolder $Latest.Version
    if ($Latest.Architecture) { $TargetFolder = Join-Path $TargetFolder $Latest.Architecture }

    # 3. Check if file already exists
    $FileName = $Latest.URI.Split('/')[-1]
    $TargetPath = Join-Path $TargetFolder $FileName

    if (Test-Path -Path $TargetPath) {
        Write-Verbose "Installer '$FileName' already exists at '$TargetFolder'. Skipping download."
        return [PSCustomObject]@{
            NewDownload = $false
            Version = $Latest.Version
            Architecture = $Latest.Architecture
            Path = $TargetPath
        }
    }

    # 4. Download and organize
    Write-Verbose "Downloading '$AppName' v$($Latest.Version) to '$TargetFolder'..."
    if (-not (Test-Path -Path $TargetFolder)) {
        New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
    }

    # Use Save-EvergreenApp for actual download
    # We pass the metadata object directly to Save-EvergreenApp
    $SavedFile = $Latest | Save-EvergreenApp -Path $TargetFolder

    return [PSCustomObject]@{
        NewDownload = $true
        Version = $Latest.Version
        Architecture = $Latest.Architecture
        Path = $SavedFile.FullName
    }
}

function Write-EvergreenSyncLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AppName,
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [string]$LogFile,
        [string]$FileName = "N/A",
        [double]$SizeMB = 0,
        [string]$Path = "N/A"
    )

    # Build log object
    $LogEntry = [PSCustomObject]@{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        AppName   = $AppName
        Status    = $Status
        FileName  = $FileName
        SizeMB    = $SizeMB
        Path      = $Path
        Message   = $Message
    }

    # Export to CSV
    if ($LogFile) {
        if (Test-Path $LogFile) {
            $LogEntry | Export-Csv -Path $LogFile -Append -NoTypeInformation
        }
        else {
            $LogEntry | Export-Csv -Path $LogFile -NoTypeInformation
        }
    }
}
