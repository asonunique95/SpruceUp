param(
    [Parameter(Mandatory=$true)]
    [string]$AppName,
    
    [Parameter(Mandatory=$true)]
    [string]$Vendor,
    
    [Parameter(Mandatory=$true)]
    [string]$Version,
    
    [Parameter(Mandatory=$false)]
    [string]$Arch,
    
    [Parameter(Mandatory=$true)]
    [string]$InstallerPath,
    
    [Parameter(Mandatory=$true)]
    [string]$PackagesPath,
    
    [Parameter(Mandatory=$true)]
    [string]$ToolkitSource,
    
    [Parameter(Mandatory=$true)]
    [string]$TemplateFile,
    
    [Parameter(Mandatory=$false)]
    [array]$ProcessesToClose = @()
)

try {
    # Handle empty Arch safely
    if ([string]::IsNullOrWhiteSpace($Arch)) { $Arch = "x64" }

    $VersionClean = $Version -replace '[^0-9.]', ''
    $PackageName = "$($Vendor)_$($AppName)_$($VersionClean)_01" -replace ' ', ''
    $CurrentPackagePath = Join-Path $PackagesPath $PackageName
    
    if (Test-Path $CurrentPackagePath) {
        return "Package '$PackageName' already exists. Skipping."
    }

    $FilesDir = Join-Path $CurrentPackagePath "Files"
    New-Item -Path $FilesDir -ItemType Directory -Force | Out-Null
    
    Copy-Item -Path $ToolkitSource -Destination $CurrentPackagePath -Recurse -Force
    Copy-Item -Path $InstallerPath -Destination $FilesDir -Force
    
    $ScriptContent = Get-Content $TemplateFile -Raw
    $ScriptContent = $ScriptContent -replace "AppVendor = ''", "AppVendor = '$Vendor'"
    $ScriptContent = $ScriptContent -replace "AppName = ''", "AppName = '$AppName'"
    $ScriptContent = $ScriptContent -replace "AppVersion = ''", "AppVersion = '$Version'"
    $ScriptContent = $ScriptContent -replace "AppArch = ''", "AppArch = '$Arch'"
    $ScriptContent = $ScriptContent -replace "AppScriptAuthor = '<author name>'", "AppScriptAuthor = 'Maldino Nikaj'"
    $ScriptContent = $ScriptContent -replace "AppScriptDate = '.*'", "AppScriptDate = '$(Get-Date -Format 'yyyy-MM-dd')'"
    
    if ($ProcessesToClose.Count -gt 0) {
        $ProcList = "@('" + ($ProcessesToClose -join "', '") + "')"
        $ScriptContent = $ScriptContent -replace "AppProcessesToClose = @\(\)", "AppProcessesToClose = $ProcList"
    }
    
    $ScriptContent | Set-Content -Path (Join-Path $CurrentPackagePath "Invoke-AppDeployToolkit.ps1") -Force
    
    return $PackageName
}
catch {
    throw "Packaging Failed: $($_.Exception.Message)"
}
