[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Name
)

# 1. Dependency Checks
if (-not (Get-Module -ListAvailable -Name "Evergreen")) {
    Write-Error "The 'Evergreen' module is required. Please install it with 'Install-Module Evergreen'."
    return
}
if (-not (Get-Module -Name "Evergreen")) { Import-Module -Name "Evergreen" }

# 2. Search for the app
Write-Verbose "Searching for '$Name' in Evergreen module..."
$Apps = Find-EvergreenApp -Name "*$Name*"

if (-not $Apps) {
    Write-Warning "No applications found matching '$Name'."
    return
}

# 3. Display matches
Write-Host "`nMatches found in Evergreen:" -ForegroundColor Cyan
$Apps | Select-Object Name, Description | Format-Table -AutoSize

# 4. If a single match is found, show detailed metadata schema
if ($Apps.Count -eq 1) {
    $AppName = $Apps[0].Name
    Write-Host "`nRetrieving detailed metadata for '$AppName' to show available filters..." -ForegroundColor Cyan
    $Metadata = Get-EvergreenApp -Name $AppName
    
    if ($Metadata) {
        Write-Host "Available Properties for Filtering (showing sample from first record):" -ForegroundColor Gray
        $Sample = $Metadata | Select-Object -First 1
        $Sample | Get-Member -MemberType NoteProperty | Select-Object Name, Definition | Format-Table -AutoSize
        
        Write-Host "Sample Data:" -ForegroundColor Gray
        $Sample | Format-List *
    }
}
elseif ($Apps.Count -gt 1) {
    Write-Host "Refine your search to a single application to see detailed metadata and available filters." -ForegroundColor Yellow
}
