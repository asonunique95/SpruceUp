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

function Set-PSADTAppHeader {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackagePath,
        [Parameter(Mandatory = $true)]
        [string]$Vendor,
        [Parameter(Mandatory = $true)]
        [string]$AppName,
        [Parameter(Mandatory = $true)]
        [string]$Version,
        [Parameter(Mandatory = $false)]
        [string]$Arch = "x64",
        [Parameter(Mandatory = $false)]
        [string[]]$ProcessesToClose = @()
    )

    $ScriptFile = Join-Path $PackagePath "Invoke-AppDeployToolkit.ps1"
    if (-not (Test-Path $ScriptFile)) {
        Write-Error "PSADT Script not found at '$ScriptFile'."
        return $false
    }

    $Content = Get-Content -Path $ScriptFile -Raw

    Write-Verbose "Injecting metadata into '$ScriptFile'..."
    
    # Replace the metadata variables in the $adtSession hashtable
    # We use regex to be more flexible with whitespace
    $Content = $Content -replace "AppVendor\s*=\s*''", "AppVendor = '$Vendor'"
    $Content = $Content -replace "AppName\s*=\s*''", "AppName = '$AppName'"
    $Content = $Content -replace "AppVersion\s*=\s*''", "AppVersion = '$Version'"
    $Content = $Content -replace "AppArch\s*=\s*''", "AppArch = '$Arch'"

    # Replace ProcessesToClose if provided
    if ($ProcessesToClose.Count -gt 0) {
        $ProcString = "@('" + ($ProcessesToClose -join "', '") + "')"
        $Content = $Content -replace "AppProcessesToClose\s*=\s*@\(\)", "AppProcessesToClose = $ProcString"
    }

    try {
        $Content | Out-File -FilePath $ScriptFile -Encoding utf8 -Force -ErrorAction Stop
        return $true
    }
    catch {
        Write-Error "Failed to write updated PSADT script: $($_.Exception.Message)"
        return $false
    }
}

function Set-PSADTInstallCommand {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackagePath,
        [Parameter(Mandatory = $true)]
        [string]$InstallerName
    )

    $ScriptFile = Join-Path $PackagePath "Invoke-AppDeployToolkit.ps1"
    if (-not (Test-Path $ScriptFile)) {
        Write-Error "PSADT Script not found at '$ScriptFile'."
        return $false
    }

    $Content = Get-Content -Path $ScriptFile -Raw

    $Extension = [System.IO.Path]::GetExtension($InstallerName).ToLower()
    
    $InstallCommand = ""
    if ($Extension -eq ".msi") {
        $InstallCommand = "Start-ADTMsiProcess -FilePath `"`$PSScriptRoot\Files\$InstallerName`" -Action Install"
    } else {
        # Default for EXE/others - assuming silent flags.
        $InstallCommand = "Start-ADTProcess -FilePath `"`$PSScriptRoot\Files\$InstallerName`" -Arguments `"/silent /norestart`""
    }

    Write-Verbose "Injecting install command for '$InstallerName' into '$ScriptFile'..."
    
    $Placeholder = "## <Perform Installation tasks here>"
    $NewContent = "`t$InstallCommand"
    
    # We use regex to replace the placeholder
    $Content = $Content -replace [regex]::Escape($Placeholder), $NewContent

    try {
        $Content | Out-File -FilePath $ScriptFile -Encoding utf8 -Force -ErrorAction Stop
        return $true
    }
    catch {
        Write-Error "Failed to write updated PSADT script with install command: $($_.Exception.Message)"
        return $false
    }
}
