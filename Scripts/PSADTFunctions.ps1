function Copy-PSADTTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath,
        [Parameter(Mandatory = $false)]
        [string]$TemplatePath = "PsApps\Temp"
    )

    # Ensure TemplatePath is absolute or relative to the script's project root
    # For now, we assume the script runs from the project root or LibraryPath is provided.
    
    if (-not (Test-Path -Path $TemplatePath)) {
        Write-Error "PSADT Template not found at '$TemplatePath'."
        return $false
    }

    if (-not (Test-Path -Path $DestinationPath)) {
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    }

    Write-Verbose "Copying PSADT Template from '$TemplatePath' to '$DestinationPath'..."
    try {
        Copy-Item -Path "$TemplatePath\*" -Destination $DestinationPath -Recurse -Force -ErrorAction Stop
        return $true
    }
    catch {
        Write-Error "Failed to copy PSADT template: $($_.Exception.Message)"
        return $false
    }
}

function Get-PSADTPackageName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Vendor,
        [Parameter(Mandatory = $true)]
        [string]$AppName,
        [Parameter(Mandatory = $true)]
        [string]$Version,
        [Parameter(Mandatory = $false)]
        [string]$Arch = "x64"
    )

    # Sanitize inputs: replace spaces and illegal characters with underscores
    $SanitizedVendor = $Vendor -replace '[\s\\/:*?"<>|]', '_'
    $SanitizedAppName = $AppName -replace '[\s\\/:*?"<>|]', '_'
    $SanitizedVersion = $Version -replace '[\s\\/:*?"<>|]', '_'
    $SanitizedArch = $Arch -replace '[\s\\/:*?"<>|]', '_'

    return "$SanitizedVendor`_$SanitizedAppName`_$SanitizedVersion`_$SanitizedArch"
}

function Stage-PSADTInstaller {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$InstallerPath,
        [Parameter(Mandatory = $true)]
        [string]$DestinationPackagePath
    )

    $FilesPath = Join-Path $DestinationPackagePath "Files"

    if (-not (Test-Path $FilesPath)) {
        New-Item -ItemType Directory -Path $FilesPath -Force | Out-Null
    }

    $InstallerFileName = Split-Path $InstallerPath -Leaf
    $DestinationFile = Join-Path $FilesPath $InstallerFileName

    Write-Verbose "Staging installer '$InstallerFileName' to '$FilesPath'..."
    try {
        Copy-Item -Path $InstallerPath -Destination $DestinationFile -Force -ErrorAction Stop
        return $true
    }
    catch {
        Write-Error "Failed to stage installer: $($_.Exception.Message)"
        return $false
    }
}
