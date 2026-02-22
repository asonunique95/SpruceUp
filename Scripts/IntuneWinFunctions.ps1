function Get-IntuneWinAppUtilPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$ToolPath
    )

    $DefaultPath = "Tools\IntuneWinAppUtil.exe"
    $SearchPath = if ([string]::IsNullOrWhiteSpace($ToolPath)) { $DefaultPath } else { $ToolPath }

    # Check if the tool exists at the provided path
    if (Test-Path -Path $SearchPath) {
        return (Resolve-Path -Path $SearchPath).Path
    }

    # Fallback: check if it's in the PATH
    $FromPath = Get-Command -Name "IntuneWinAppUtil.exe" -ErrorAction SilentlyContinue
    if ($FromPath) {
        return $FromPath.Source
    }

    $DownloadUrl = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool"
    Write-Error "IntuneWinAppUtil.exe not found. Please download it from $DownloadUrl and place it in the 'Tools\' folder, or add it to your system PATH."
    return $null
}

function New-IntuneWinPackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceFolder,
        [Parameter(Mandatory = $true)]
        [string]$SetupFile,
        [Parameter(Mandatory = $true)]
        [string]$OutputFolder,
        [Parameter(Mandatory = $false)]
        [string]$OutputFileName,
        [Parameter(Mandatory = $false)]
        [string]$ToolPath = "Tools\IntuneWinAppUtil.exe"
    )

    $ExePath = Get-IntuneWinAppUtilPath -ToolPath $ToolPath
    if (-not $ExePath) { return $false }

    # Ensure output folder exists
    if (-not (Test-Path -Path $OutputFolder)) {
        Write-Verbose "Creating output directory: $OutputFolder"
        New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
    }

    $FullSource = (Resolve-Path -Path $SourceFolder).Path
    $FullOutput = (Resolve-Path -Path $OutputFolder).Path

    # Ensure setup file exists in source folder
    $FullSetupFile = Join-Path $FullSource $SetupFile
    if (-not (Test-Path -Path $FullSetupFile)) {
        Write-Error "Setup file '$SetupFile' not found in source folder '$FullSource'."
        return $false
    }

    Write-Verbose "Creating .intunewin package for '$SetupFile' from '$FullSource'..."
    
    # IntuneWinAppUtil.exe -c <setup_folder> -s <setup_file> -o <output_folder>
    $Args = "-c `"$FullSource`" -s `"$SetupFile`" -o `"$FullOutput`" -q"
    
    try {
        $Process = Start-Process -FilePath $ExePath -ArgumentList $Args -Wait -NoNewWindow -PassThru -ErrorAction Stop
        if ($Process.ExitCode -eq 0) {
            # IntuneWinAppUtil always names it after the setup file: <setupfile_base>.intunewin
            $DefaultGeneratedFileName = [System.IO.Path]::ChangeExtension($SetupFile, ".intunewin")
            $GeneratedFilePath = Join-Path $FullOutput $DefaultGeneratedFileName
            
            # If a custom name is requested, rename the file
            if (-not [string]::IsNullOrWhiteSpace($OutputFileName)) {
                if ($OutputFileName -notlike "*.intunewin") { $OutputFileName += ".intunewin" }
                $NewFilePath = Join-Path $FullOutput $OutputFileName
                
                if (Test-Path $GeneratedFilePath) {
                    Write-Verbose "Renaming '$DefaultGeneratedFileName' to '$OutputFileName'..."
                    Move-Item -Path $GeneratedFilePath -Destination $NewFilePath -Force
                    $GeneratedFilePath = $NewFilePath
                }
            }

            Write-Verbose "Successfully created .intunewin package: $GeneratedFilePath"
            return $GeneratedFilePath
        } else {
            Write-Error "IntuneWinAppUtil failed with exit code $($Process.ExitCode)."
            return $false
        }
    }
    catch {
        Write-Error "Failed to run IntuneWinAppUtil: $($_.Exception.Message)"
        return $false
    }
}
