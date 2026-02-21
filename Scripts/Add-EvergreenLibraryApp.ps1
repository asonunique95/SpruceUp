[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Name,
    
    [Parameter(Mandatory = $true)]
    [string]$Vendor,
    
    [Parameter(Mandatory = $true)]
    [string]$EvergreenApp,
    
    [Parameter(Mandatory = $true)]
    [string]$Filter,
    
    [Parameter(Mandatory = $false)]
    [string]$LibraryPath = "C:\Evergreen",
    
    [Parameter(Mandatory = $false)]
    [string]$ConfigFile = "EvergreenLibrary.json"
)

# 1. Setup Path
$FullConfigPath = Join-Path $LibraryPath $ConfigFile

if (-not (Test-Path $FullConfigPath)) {
    Write-Error "Config file not found at '$FullConfigPath'."
    return
}

# 2. Load Manifest
Write-Verbose "Loading manifest from '$FullConfigPath'..."
try {
    $RawJson = Get-Content -Path $FullConfigPath -Raw -ErrorAction Stop
    $Manifest = $RawJson | ConvertFrom-Json -ErrorAction Stop
}
catch {
    Write-Error "Failed to read or parse manifest: $($_.Exception.Message)"
    return
}

# 3. Check for duplicates
$ExistingByName = $Manifest.Applications | Where-Object { $_.Name -eq $Name }
$ExistingByApp = $Manifest.Applications | Where-Object { $_.EvergreenApp -eq $EvergreenApp }

if ($ExistingByName -or $ExistingByApp) {
    if ($ExistingByName) { Write-Warning "An entry with Name '$Name' already exists." }
    if ($ExistingByApp) { Write-Warning "An entry with EvergreenApp '$EvergreenApp' already exists." }
    
    $Confirm = Read-Host "`nDo you want to proceed and add a potential duplicate? (y/n)"
    if ($Confirm -ne "y") { 
        Write-Host "Operation cancelled." -ForegroundColor Gray
        return 
    }
}

# 4. Create new entry
$NewApp = [PSCustomObject]@{
    Name         = $Name
    Vendor       = $Vendor
    EvergreenApp = $EvergreenApp
    Filter       = $Filter
}

# 5. Append and Save
Write-Host "Adding '$Name' to manifest..." -ForegroundColor Cyan
$Manifest.Applications += $NewApp

try {
    # Sort apps alphabetically by name for better maintainability
    $Manifest.Applications = $Manifest.Applications | Sort-Object Name
    
    $Manifest | ConvertTo-Json -Depth 10 | Out-File -FilePath $FullConfigPath -Encoding utf8 -Force -ErrorAction Stop
    Write-Host "Successfully updated '$FullConfigPath'." -ForegroundColor Green
}
catch {
    Write-Error "Failed to save updated manifest: $($_.Exception.Message)"
}
