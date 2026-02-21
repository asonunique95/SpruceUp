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
$Manifest = Get-Content -Path $FullConfigPath -Raw | ConvertFrom-Json

# 3. Check for duplicates
$Existing = $Manifest.Applications | Where-Object { $_.Name -eq $Name -or $_.EvergreenApp -eq $EvergreenApp }
if ($Existing) {
    Write-Warning "An application with Name '$Name' or EvergreenApp '$EvergreenApp' already exists in the manifest."
    $Confirm = Read-Host "Do you want to proceed and add a potential duplicate? (y/n)"
    if ($Confirm -ne "y") { return }
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
    $Manifest | ConvertTo-Json -Depth 10 | Out-File -FilePath $FullConfigPath -Encoding utf8 -Force -ErrorAction Stop
    Write-Host "Successfully updated '$FullConfigPath'." -ForegroundColor Green
}
catch {
    Write-Error "Failed to save updated manifest: $($_.Exception.Message)"
}
