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
    
    # Return the applications array if valid
    if ($null -eq $JsonContent.Applications -or $JsonContent.Applications.Count -eq 0) {
        throw "The manifest at '$Path' is missing the 'Applications' property or contains no apps."
    }

    # Basic schema check for each app
    foreach ($App in $JsonContent.Applications) {
        if (-not $App.Name -or -not $App.EvergreenApp) {
            throw "Invalid application entry found. 'Name' and 'EvergreenApp' are required fields."
        }
    }

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
        [string]$LibraryPath,
        [Parameter(Mandatory = $false)]
        [string]$DataPath
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

    # 2. Build root folder for the application
    # Use DataPath for storage if provided, otherwise fallback to LibraryPath/Installers
    $AppRoot = if ([string]::IsNullOrWhiteSpace($DataPath)) { 
        Join-Path $LibraryPath "Installers" 
    } else { 
        $DataPath 
    }
    
    $AppRoot = Join-Path $AppRoot $Publisher
    $AppRoot = Join-Path $AppRoot $AppName

    # 3. Build expected target path for the check (mimicking Save-EvergreenApp behavior)
    $ExpectedFolder = $AppRoot
    if ($Latest.Channel) { $ExpectedFolder = Join-Path $ExpectedFolder $Latest.Channel }
    if ($Latest.Version) { $ExpectedFolder = Join-Path $ExpectedFolder $Latest.Version }
    if ($Latest.Architecture) { $ExpectedFolder = Join-Path $ExpectedFolder $Latest.Architecture }

    $FileName = $Latest.URI.Split('/')[-1]
    $TargetPath = Join-Path $ExpectedFolder $FileName

    if (Test-Path -Path $TargetPath) {
        Write-Verbose "Installer '$FileName' already exists at '$ExpectedFolder'. Skipping download."
        return [PSCustomObject]@{
            NewDownload = $false
            Version = $Latest.Version
            Architecture = $Latest.Architecture
            Path = $TargetPath
        }
    }

    # 4. Download and organize
    Write-Verbose "Downloading '$AppName' v$($Latest.Version) to '$AppRoot'..."
    if (-not (Test-Path -Path $AppRoot)) {
        New-Item -ItemType Directory -Path $AppRoot -Force | Out-Null
    }

    # Use Save-EvergreenApp for actual download with retry logic
    $MaxRetries = 3
    $RetryCount = 0
    $SavedFile = $null
    $Success = $false

    while (-not $Success -and $RetryCount -lt $MaxRetries) {
        try {
            # We pass the metadata object directly to Save-EvergreenApp
            # Save-EvergreenApp adds Channel/Version/Architecture subfolders automatically
            $SavedFile = $Latest | Save-EvergreenApp -Path $AppRoot -ErrorAction Stop
            $Success = $true
        }
        catch {
            $RetryCount++
            Write-Warning "Download failed for '$AppName' (Attempt $RetryCount of $MaxRetries): $($_.Exception.Message)"
            if ($RetryCount -lt $MaxRetries) {
                Start-Sleep -Seconds (5 * $RetryCount) # Exponential backoff
            }
            else {
                throw "Failed to download '$AppName' after $MaxRetries attempts."
            }
        }
    }

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
