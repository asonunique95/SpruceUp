$LibraryPath = "C:\Evergreen"
$ConfigFile = Join-Path $LibraryPath "EvergreenLibrary.json"
$DeployConfigFile = Join-Path $LibraryPath "DeploymentConfig.json"
$LogFile = Join-Path $LibraryPath "EvergreenSyncLog.csv"
$ToolkitSource = "C:\Evergreen\PsApps\Temp\PSAppDeployToolkit"
$TemplateFile = "C:\Evergreen\PsApps\Temp\Invoke-AppDeployToolkit.ps1"
$PackagesPath = Join-Path $LibraryPath "Packages"

# 1. Dependency Checks
if (-not (Get-Module -ListAvailable -Name "Evergreen")) {
    Write-Error "The 'Evergreen' module is not installed."
    return
}
if (-not (Get-Module -Name "Evergreen")) { Import-Module -Name "Evergreen" }
if (-not (Test-Path $ConfigFile)) { Write-Error "Missing $ConfigFile"; return }

# 2. Load Configurations
$Config = Get-Content $ConfigFile | ConvertFrom-Json
$DeployConfig = if (Test-Path $DeployConfigFile) { Get-Content $DeployConfigFile | ConvertFrom-Json } else { $null }
$Apps = $Config.Applications
$Total = $Apps.Count
$Index = 0
$Results = @()

Write-Host "`nStarting Evergreen Sync & PSADT Packaging..." -ForegroundColor Cyan

foreach ($App in $Apps) {
    $Index++
    Write-Progress -Activity "Evergreen Sync & Package" -Status "Processing: $($App.Name)" -PercentComplete (($Index / $Total) * 100)

    try {
        Write-Host "Syncing $($App.Name)... " -NoNewline -ForegroundColor White
        $AppDetails = Get-EvergreenApp -Name $App.EvergreenApp -WarningAction SilentlyContinue
        $FilterScript = [scriptblock]::Create($App.Filter)
        
        $FilteredApp = $AppDetails | Where-Object {
            $inputObject = $_
            & $FilterScript
        } | Sort-Object Version -Descending | Select-Object -First 1

        if ($FilteredApp) {
            $AppFolder = Join-Path $LibraryPath $App.Name
            $SavedFiles = $FilteredApp | Save-EvergreenApp -Path $AppFolder -WarningAction SilentlyContinue
            
            if ($null -ne $SavedFiles) {
                Write-Host "Done (v$($FilteredApp.Version))." -ForegroundColor Green
                
                foreach ($File in $SavedFiles) {
                    $PathToLog = if ($File.Path) { $File.Path } else { $File.ToString() }
                    if (Test-Path $PathToLog) {
                        $FileInfo = Get-Item $PathToLog
                        
                        # Prepare Package Folder
                        $VersionClean = $FilteredApp.Version -replace '[^0-9.]', ''
                        $PackageName = "$($App.Vendor)_$($App.Name)_$($VersionClean)_01" -replace ' ', ''
                        $CurrentPackagePath = Join-Path $PackagesPath $PackageName
                        
                        if (-not (Test-Path $CurrentPackagePath)) {
                            Write-Host "  -> Creating PSADT Package: $PackageName" -ForegroundColor Cyan
                            
                            # CREATE DIRECTORIES FIRST
                            $FilesDir = Join-Path $CurrentPackagePath "Files"
                            New-Item -Path $FilesDir -ItemType Directory -Force | Out-Null
                            
                            # Copy Toolkit Core
                            Copy-Item -Path $ToolkitSource -Destination $CurrentPackagePath -Recurse -Force
                            
                            # COPY INSTALLER INTO FILES SUBDIR
                            Copy-Item -Path $PathToLog -Destination $FilesDir -Force
                            
                            # Customize Invoke-AppDeployToolkit.ps1
                            $ScriptContent = Get-Content $TemplateFile -Raw
                            $ScriptContent = $ScriptContent -replace "AppVendor = ''", "AppVendor = '$($App.Vendor)'"
                            $ScriptContent = $ScriptContent -replace "AppName = ''", "AppName = '$($App.Name)'"
                            $ScriptContent = $ScriptContent -replace "AppVersion = ''", "AppVersion = '$($FilteredApp.Version)'"
                            $ScriptContent = $ScriptContent -replace "AppArch = ''", "AppArch = '$($FilteredApp.Architecture)'"
                            $ScriptContent = $ScriptContent -replace "AppScriptAuthor = '<author name>'", "AppScriptAuthor = 'Maldino Nikaj'"
                            $ScriptContent = $ScriptContent -replace "AppScriptDate = '.*'", "AppScriptDate = '$(Get-Date -Format 'yyyy-MM-dd')'"
                            
                            # Handle ProcessesToClose from DeploymentConfig.json if available
                            if ($DeployConfig -and $DeployConfig.$($App.Name).ProcessesToClose) {
                                $ProcList = "@('" + ($DeployConfig.$($App.Name).ProcessesToClose -join "', '") + "')"
                                $ScriptContent = $ScriptContent -replace "AppProcessesToClose = @\(\)", "AppProcessesToClose = $ProcList"
                            }
                            
                            $ScriptContent | Set-Content -Path (Join-Path $CurrentPackagePath "Invoke-AppDeployToolkit.ps1") -Force
                        }

                        $Results += [PSCustomObject]@{
                            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; AppName = $App.Name; Status = "Success"
                            FileName = $FileInfo.Name; Path = $PathToLog; Message = "Packaged v$($FilteredApp.Version)"
                        }
                    }
                }
            } else {
                Write-Host "Up to date." -ForegroundColor Gray
            }
        }
    }
    catch {
        Write-Host "Error!" -ForegroundColor Red
        Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nAll apps processed. Packages in: $PackagesPath" -ForegroundColor Green
