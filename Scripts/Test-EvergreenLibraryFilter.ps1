[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$EvergreenApp
)

# 1. Dependency Checks
if (-not (Get-Module -ListAvailable -Name "Evergreen")) {
    Write-Error "The 'Evergreen' module is required."
    return
}
if (-not (Get-Module -Name "Evergreen")) { Import-Module -Name "Evergreen" }

# 2. Fetch all metadata for the app
Write-Host "Fetching all metadata for '$EvergreenApp'..." -ForegroundColor Cyan
$AllMetadata = $null
try {
    $AllMetadata = Get-EvergreenApp -Name $EvergreenApp -ErrorAction Stop
}
catch {
    Write-Error "Failed to retrieve metadata for '$EvergreenApp': $($_.Exception.Message)"
    return
}

if (-not $AllMetadata) {
    Write-Error "No metadata found for '$EvergreenApp'."
    return
}

Write-Host "Found $($AllMetadata.Count) records. Starting interactive filter test." -ForegroundColor Gray
Write-Host "Enter your filter string (PowerShell syntax, e.g., `$_.Channel -eq 'Stable'`)." -ForegroundColor Gray
Write-Host "Type 'exit' to quit or 'done' if you are happy with the results." -ForegroundColor Gray

$FinalFilter = $null

# 3. Interactive Loop
while ($true) {
    $FilterInput = Read-Host "`nFilter"
    
    if ($FilterInput -eq "exit") { break }
    if ($FilterInput -eq "done") { 
        if ($FinalFilter) {
            Write-Host "`nFinal Filter Choice: $FinalFilter" -ForegroundColor Green
        }
        break 
    }

    try {
        $Results = $AllMetadata | Where-Object { Invoke-Expression -Command $FilterInput }
        
        if ($Results) {
            Write-Host "`nMatches found ($($Results.Count)):" -ForegroundColor Green
            
            # Display dynamic columns based on what's available
            $Columns = @('Channel', 'Version', 'Architecture', 'Type', 'Language', 'Release') | Where-Object { $Results[0].$_ }
            $Results | Select-Object $Columns | Format-Table -AutoSize
            
            # Matched Metadata Summary (for Add-EvergreenLibraryApp.ps1)
            Write-Host "`nMatched Metadata Summary (for registration):" -ForegroundColor Cyan
            $Sample = $Results | Select-Object -First 1
            $Summary = [PSCustomObject]@{
                EvergreenApp = $EvergreenApp
                Vendor       = if ($Sample.Publisher) { $Sample.Publisher } elseif ($Sample.Vendor) { $Sample.Vendor } else { "<Unknown>" }
                SampleName   = $Sample.Name
                Filter       = $FilterInput
            }
            $Summary | Format-List
            
            $FinalFilter = $FilterInput
        }
        else {
            Write-Host "`nNo matches found with that filter." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "`nInvalid filter syntax: $($_.Exception.Message)" -ForegroundColor Red
    }
}

if ($FinalFilter) {
    return $FinalFilter
}
