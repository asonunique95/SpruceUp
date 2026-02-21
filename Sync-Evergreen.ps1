param(
    [Parameter(Mandatory=$false)]
    [switch]$ListAvailable,

    [Parameter(Mandatory=$false)]
    [string]$AppName
)

$LibraryPath = "C:\Evergreen"
$ConfigFile = Join-Path $LibraryPath "EvergreenLibrary.json"
$DeployConfigFile = Join-Path $LibraryPath "DeploymentConfig.json"
$LogFile = Join-Path $LibraryPath "EvergreenSyncLog.csv"
$ToolkitSource = "C:\Evergreen\PsApps\Temp\PSAppDeployToolkit"
$TemplateFile = "C:\Evergreen\PsApps\Temp\Invoke-AppDeployToolkit.ps1"
$PackagesPath = Join-Path $LibraryPath "Packages"

# 1. Dependency Checks
if (-not (Get-Module -ListAvailable -Name "Evergreen")) { Write-Error "Evergreen module missing."; return }
if (-not (Get-Module -Name "Evergreen")) { Import-Module -Name "Evergreen" }
if (-not (Test-Path $ConfigFile)) { Write-Error "Missing $ConfigFile"; return }

# 2. Load Configurations
$Config = Get-Content $ConfigFile | ConvertFrom-Json
$DeployConfig = if (Test-Path $DeployConfigFile) { Get-Content $DeployConfigFile | ConvertFrom-Json } else { $null }
$Apps = $Config.Applications

# --- HANDLE LIST PARAMETER ---
if ($ListAvailable) {
    Write-Host "`nApps defined in $ConfigFile`:" -ForegroundColor Cyan
    $Apps | Select-Object Name, Vendor, EvergreenApp | Format-Table -AutoSize
    return
}

# --- HANDLE APPNAME PARAMETER ---
if ($null -ne $AppName -and $AppName -ne "") {
    $Apps = $Apps | Where-Object { $_.Name -eq $AppName }
    if (-not $Apps) {
        Write-Error "App '$AppName' not found in $ConfigFile"
        return
    }
}

$Total = $Apps.Count
$Index = 0

Write-Host "`nStarting Orchestrated Evergreen Sync & Packaging for $Total apps..." -ForegroundColor Cyan

foreach ($App in $Apps) {
    $Index++
    Write-Progress -Activity "Sync & Package" -Status "Checking: $($App.Name)" -PercentComplete (($Index / $Total) * 100)

    try {
        Write-Host "Syncing $($App.Name)... " -NoNewline -ForegroundColor White
        
        $SyncInfo = & (Join-Path $LibraryPath "Scripts\Get-EvergreenSync.ps1") `
                     -EvergreenApp $App.EvergreenApp `
                     -Filter $App.Filter `
                     -LibraryPath $LibraryPath `
                     -AppName $App.Name
        
        if ($null -ne $SyncInfo) {
            if ($SyncInfo.NewDownload) {
                Write-Host "New (v$($SyncInfo.Version))." -ForegroundColor Green
                $ProcList = if ($DeployConfig -and $DeployConfig.$($App.Name).ProcessesToClose) { $DeployConfig.$($App.Name).ProcessesToClose } else { @() }
                
                $PackageResult = & (Join-Path $LibraryPath "Scripts\New-PSADTPackage.ps1") `
                                  -AppName $App.Name `
                                  -Vendor $App.Vendor `
                                  -Version $SyncInfo.Version `
                                  -Arch $SyncInfo.Architecture `
                                  -InstallerPath $SyncInfo.Path `
                                  -PackagesPath $PackagesPath `
                                  -ToolkitSource $ToolkitSource `
                                  -TemplateFile $TemplateFile `
                                  -ProcessesToClose $ProcList
                
                if (Test-Path $SyncInfo.Path) {
                    $FileInfo = Get-Item $SyncInfo.Path
                    & (Join-Path $LibraryPath "Scripts\Write-SyncLog.ps1") `
                      -AppName $App.Name -Status "Success" -Message "New package: $PackageResult" `
                      -LogFile $LogFile -FileName $FileInfo.Name -SizeMB ([math]::Round($FileInfo.Length/1MB,2)) -Path $SyncInfo.Path
                    Write-Host "  -> Package Created: $PackageResult" -ForegroundColor DarkGreen
                }
            } else {
                Write-Host "Up to date." -ForegroundColor Gray
            }
        } else {
            Write-Host "Filtered." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error!" -ForegroundColor Red
        Write-Host "  -> $($_.Exception.Message)" -ForegroundColor Red
        & (Join-Path $LibraryPath "Scripts\Write-SyncLog.ps1") -AppName $App.Name -Status "Error" -Message $_.Exception.Message -LogFile $LogFile
    }
}

Write-Host "`nOrchestration Complete!" -ForegroundColor Green
