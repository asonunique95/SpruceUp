[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$AppName,

    [Parameter(Mandatory = $true)]
    [string]$Vendor,

    [Parameter(Mandatory = $true)]
    [string]$Version,

    [Parameter(Mandatory = $false)]
    [string]$Architecture = "x64",

    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [Parameter(Mandatory = $false)]
    [string]$LibraryPath = "C:\Evergreen",

    [Parameter(Mandatory = $false)]
    [string]$DeployConfigFile = "DeploymentConfig.json"
)

# 1. Validation
if (-not (Test-Path -Path $SourcePath)) {
    throw "Source file not found at '$SourcePath'."
}

# 2. Function Import
$ScriptPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. (Join-Path $ScriptPath "Scripts\PSADTFunctions.ps1")
. (Join-Path $ScriptPath "Scripts\IntuneWinFunctions.ps1")

# 3. Setup Paths
$FullDeployConfigPath = Join-Path $LibraryPath $DeployConfigFile
$PackagesPath = Join-Path $LibraryPath "Packages"
$IntuneWinPath = Join-Path $PackagesPath "IntuneWin"

# 4. Ensure Directories Exist
foreach ($Path in @($PackagesPath, $IntuneWinPath)) {
    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

# 5. Load Deployment Config
# We use -AsHashtable to allow dynamic property addition
$DeployConfig = if (Test-Path $FullDeployConfigPath) { 
    Get-Content -Path $FullDeployConfigPath -Raw | ConvertFrom-Json -AsHashtable 
} else { 
    @{} 
}

# 5.1 Create/Update entry if it doesn't exist
if (-not $DeployConfig.$AppName) {
    Write-Host "  -> Adding default entry to $DeployConfigFile..." -ForegroundColor Gray
    
    $InstallerName = Split-Path $SourcePath -Leaf
    $Extension = [System.IO.Path]::GetExtension($InstallerName).ToLower()
    
    $DefaultInstall = if ($Extension -eq ".msi") {
        'Start-ADTMsiProcess -FilePath "$PSScriptRoot\Files\{InstallerName}" -Action Install -Arguments "/qn /norestart"'
    } else {
        'Start-ADTProcess -FilePath "$PSScriptRoot\Files\{InstallerName}" -Arguments "/silent /norestart"'
    }

    $DeployConfig.$AppName = @{
        Vendor = $Vendor
        InstallCommand = $DefaultInstall
        UninstallCommand = if ($Extension -eq ".msi") { 'Execute-MSI -Action Uninstall -Path "{ProductCode}"' } else { "" }
        ProcessesToClose = @()
    }

    $DeployConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath $FullDeployConfigPath -Encoding utf8 -Force
}

# 6. Process Packaging
Write-Host "Manual Import: Starting packaging for $AppName v$Version ($Architecture)..." -ForegroundColor Cyan

try {
    $PackageName = Get-PSADTPackageName -Vendor $Vendor -AppName $AppName -Version $Version -Arch $Architecture
    $PackageFolder = Join-Path $PackagesPath $PackageName
    
    # Get app-specific config
    $AppDeploy = if ($DeployConfig -and $DeployConfig.$($AppName)) { $DeployConfig.$($AppName) } else { $null }
    $ProcList = if ($AppDeploy -and $AppDeploy.ProcessesToClose) { $AppDeploy.ProcessesToClose } else { @() }
    $CustomInstall = if ($AppDeploy -and $AppDeploy.InstallCommand) { $AppDeploy.InstallCommand } else { $null }
    $CustomUninstall = if ($AppDeploy -and $AppDeploy.UninstallCommand) { $AppDeploy.UninstallCommand } else { $null }

    Write-Host "  -> Creating PSADT package... " -NoNewline
    Copy-PSADTTemplate -DestinationPath $PackageFolder | Out-Null
    Stage-PSADTInstaller -InstallerPath $SourcePath -DestinationPackagePath $PackageFolder | Out-Null
    Set-PSADTAppHeader -PackagePath $PackageFolder -Vendor $Vendor -AppName $AppName -Version $Version -Arch $Architecture -ProcessesToClose $ProcList | Out-Null
    Set-PSADTInstallCommand -PackagePath $PackageFolder -InstallerName (Split-Path $SourcePath -Leaf) -CustomCommand $CustomInstall | Out-Null
    
    if ($CustomUninstall) {
        Set-PSADTUninstallCommand -PackagePath $PackageFolder -CustomCommand $CustomUninstall | Out-Null
    }
    Write-Host "Done." -ForegroundColor DarkGreen

    # --- INTUNEWIN CONVERSION ---
    Write-Host "  -> Converting to .intunewin... " -NoNewline
    $IntuneWinFile = New-IntuneWinPackage -SourceFolder $PackageFolder `
                                         -SetupFile "Invoke-AppDeployToolkit.exe" `
                                         -OutputFolder $IntuneWinPath `
                                         -OutputFileName $PackageName
    
    if ($IntuneWinFile) {
        Write-Host "Done." -ForegroundColor DarkGreen
        Write-Host "`nSuccessfully created: $IntuneWinFile" -ForegroundColor Green
        return $IntuneWinFile
    } else {
        Write-Host "Failed!" -ForegroundColor Red
        return $null
    }
}
catch {
    Write-Error "Failed to package local application: $($_.Exception.Message)"
    return $null
}
