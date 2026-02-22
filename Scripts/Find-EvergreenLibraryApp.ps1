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
$Apps = $null

try {
    # The Evergreen module handles partial matches (often via Regex)
    # Adding manual glob wildcards (*) causes errors in recent versions
    $Apps = Find-EvergreenApp -Name $Name -ErrorAction Stop
}
catch {
    # If a regex error occurs, try escaping the search term
    try {
        $EscapedName = [regex]::Escape($Name)
        $Apps = Find-EvergreenApp -Name $EscapedName -ErrorAction SilentlyContinue
    }
    catch {
        Write-Error "An error occurred while searching for '$Name': $($_.Exception.Message)"
        return
    }
}

if (-not $Apps) {
    Write-Warning "No applications found matching '$Name' in the Evergreen module."
    Write-Host "Try a broader search term or check the available apps at https://steve0hun.github.io/Evergreen/apps/" -ForegroundColor Gray
    return
}

# 3. Display matches
Write-Host "`nMatches found in Evergreen:" -ForegroundColor Cyan
$Apps | Select-Object Name, Description | Format-Table -AutoSize

# 4. If a single match is found, show detailed metadata schema
if ($Apps.Count -eq 1 -or ($null -ne $Apps -and $Apps.GetType().Name -notlike "*[]")) {
    $AppName = if ($Apps.Count -eq 1) { $Apps[0].Name } else { $Apps.Name }
    
    Write-Host "`nRetrieving detailed metadata for '$AppName' to show available filters..." -ForegroundColor Cyan
    try {
        $Metadata = Get-EvergreenApp -Name $AppName -ErrorAction Stop
        
        if ($Metadata) {
            Write-Host "Available Properties for Filtering (showing sample from first record):" -ForegroundColor Gray
            $Sample = $Metadata | Select-Object -First 1
            $Sample | Get-Member -MemberType NoteProperty | Select-Object Name, Definition | Format-Table -AutoSize
            
            Write-Host "Sample Data Summary:" -ForegroundColor Gray
            $Sample | Format-List *
        }
    }
    catch {
        Write-Warning "Could not retrieve detailed metadata for '$AppName': $($_.Exception.Message)"
    }
}
elseif ($Apps.Count -gt 1) {
    Write-Host "Refine your search to a single application to see detailed metadata and available filters." -ForegroundColor Yellow
}
