param(
    [Parameter(Mandatory=$true)]
    [string]$AppName,
    
    [Parameter(Mandatory=$true)]
    [string]$Status,
    
    [Parameter(Mandatory=$true)]
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
    } else {
        $LogEntry | Export-Csv -Path $LogFile -NoTypeInformation
    }
}
