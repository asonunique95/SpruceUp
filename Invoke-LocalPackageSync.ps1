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
    [string]$DataPath,

    [Parameter(Mandatory = $false)]
    [string]$InstallersPath,

    [Parameter(Mandatory = $false)]
    [string]$PackagesPath,

    [Parameter(Mandatory = $false)]
    [string]$DeployConfigFile = "DeploymentConfig.json",

    [Parameter(Mandatory = $false)]
    [string]$TextLog = "SpruceUp.log",

    [Parameter(Mandatory = $false)]
    [string]$SummaryLog = "ManualSyncSummary.csv"
)

# 1. Validation
if (-not (Test-Path -Path $SourcePath)) {
    throw "Source file not found at '$SourcePath'."
}

# 2. Function Import
$ScriptPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. (Join-Path $ScriptPath "Scripts\LibraryFunctions.ps1")
. (Join-Path $ScriptPath "Scripts\PSADTFunctions.ps1")
. (Join-Path $ScriptPath "Scripts\IntuneWinFunctions.ps1")

# 3. Setup Paths
$FullDeployConfigPath = Join-Path $LibraryPath $DeployConfigFile
$FullTextLogPath = Join-Path $LibraryPath $TextLog
$FullSummaryLogPath = Join-Path $LibraryPath $SummaryLog

$FinalPackagesPath = if ($PackagesPath) { $PackagesPath } elseif ($DataPath) { Join-Path $DataPath "Packages" } else { Join-Path $LibraryPath "Packages" }
$FinalIntuneWinPath = Join-Path $FinalPackagesPath "IntuneWin"

# 4. Ensure Directories Exist
foreach ($Path in @($FinalPackagesPath, $FinalIntuneWinPath)) {
    if (-not (Test-Path -Path $Path)) {
        try {
            Write-Verbose "Creating directory: $Path"
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
        }
        catch {
            Write-Error "Failed to create directory at '$Path'. If this is a network share, ensure you have provided the share name (e.g. \\homestor\Share) and have write permissions."
            return
        }
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
    Write-SpruceLog -Message "  -> Adding default entry to $DeployConfigFile..." -Level "INFO" -LogFile $FullTextLogPath
    
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
        UninstallCommand = ""
        ProcessesToClose = @()
    }

    $DeployConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath $FullDeployConfigPath -Encoding utf8 -Force
}

# 6. Process Packaging
Write-SpruceLog -Message "Manual Import: Starting packaging for $AppName v$Version ($Architecture)..." -Level "INFO" -LogFile $FullTextLogPath

try {
    $PackageName = Get-PSADTPackageName -Vendor $Vendor -AppName $AppName -Version $Version -Arch $Architecture
    $PackageFolder = Join-Path $FinalPackagesPath $PackageName
    
    # Get app-specific config
    $AppDeploy = if ($DeployConfig -and $DeployConfig.$($AppName)) { $DeployConfig.$($AppName) } else { $null }
    $ProcList = if ($AppDeploy -and $AppDeploy.ProcessesToClose) { $AppDeploy.ProcessesToClose } else { @() }
    $CustomInstall = if ($AppDeploy -and $AppDeploy.InstallCommand) { $AppDeploy.InstallCommand } else { $null }
    $CustomUninstall = if ($AppDeploy -and $AppDeploy.UninstallCommand) { $AppDeploy.UninstallCommand } else { $null }

    Write-SpruceLog -Message "  -> Creating PSADT package..." -Level "INFO" -LogFile $FullTextLogPath
    Copy-PSADTTemplate -DestinationPath $PackageFolder | Out-Null
    Stage-PSADTInstaller -InstallerPath $SourcePath -DestinationPackagePath $PackageFolder | Out-Null
    Set-PSADTAppHeader -PackagePath $PackageFolder -Vendor $Vendor -AppName $AppName -Version $Version -Arch $Architecture -ProcessesToClose $ProcList | Out-Null
    
    $InstallerFileName = Split-Path $SourcePath -Leaf
    Set-PSADTInstallCommand -PackagePath $PackageFolder -InstallerName $InstallerFileName -CustomCommand $CustomInstall | Out-Null
    Set-PSADTUninstallCommand -PackagePath $PackageFolder -InstallerName $InstallerFileName -CustomCommand $CustomUninstall | Out-Null
    
    Write-SpruceLog -Message "Done." -Level "INFO" -LogFile $FullTextLogPath

    # --- INTUNEWIN CONVERSION ---
    Write-SpruceLog -Message "  -> Converting to .intunewin..." -Level "INFO" -LogFile $FullTextLogPath
    $IntuneWinFile = New-IntuneWinPackage -SourceFolder $PackageFolder `
                                         -SetupFile "Invoke-AppDeployToolkit.exe" `
                                         -OutputFolder $FinalIntuneWinPath `
                                         -OutputFileName $PackageName
    
    if ($IntuneWinFile) {
        Write-SpruceLog -Message "Done." -Level "INFO" -LogFile $FullTextLogPath
        Write-SpruceLog -Message "`nSuccessfully created: $IntuneWinFile" -Level "INFO" -LogFile $FullTextLogPath
        
        Write-SpruceLog -Message "Manual Import Successful" -Level "INFO" -LogFile $FullTextLogPath -CsvFile $FullSummaryLogPath -Summary @{
            AppName = $AppName
            Version = $Version
            Status  = "Success"
            Path    = $IntuneWinFile
        }

        return $IntuneWinFile
    } else {
        Write-SpruceLog -Message "Failed!" -Level "ERROR" -LogFile $FullTextLogPath
        
        Write-SpruceLog -Message "Manual Import Failed (IntuneWin conversion)" -Level "ERROR" -LogFile $FullTextLogPath -CsvFile $FullSummaryLogPath -Summary @{
            AppName = $AppName
            Version = $Version
            Status  = "Error"
            Path    = $null
        }

        return $null
    }
}
catch {
    Write-SpruceLog -Message "Failed to package local application: $($_.Exception.Message)" -Level "ERROR" -LogFile $FullTextLogPath
    
    Write-SpruceLog -Message $_.Exception.Message -Level "ERROR" -LogFile $FullTextLogPath -CsvFile $FullSummaryLogPath -Summary @{
        AppName = $AppName
        Version = $Version
        Status  = "Error"
        Path    = $null
    }

    return $null
}
