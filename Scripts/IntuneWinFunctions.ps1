function Get-IntuneWinAppUtilPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$ToolPath = "Tools\IntuneWinAppUtil.exe"
    )

    # Check if the tool exists at the provided path
    if (Test-Path -Path $ToolPath) {
        return (Resolve-Path -Path $ToolPath).Path
    }

    # Fallback: check if it's in the PATH
    $FromPath = Get-Command -Name "IntuneWinAppUtil.exe" -ErrorAction SilentlyContinue
    if ($FromPath) {
        return $FromPath.Source
    }

    Write-Error "IntuneWinAppUtil.exe not found at '$ToolPath' or in system PATH."
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
        [string]$ToolPath
    )

    $ExePath = Get-IntuneWinAppUtilPath -ToolPath $ToolPath
    if (-not $ExePath) { return $false }

    if (-not (Test-Path -Path $OutputFolder)) {
        New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
    }

    $FullSource = (Resolve-Path -Path $SourceFolder).Path
    $FullOutput = (Resolve-Path -Path $OutputFolder).Path

    Write-Verbose "Creating .intunewin package for '$SetupFile' from '$FullSource'..."
    
    # IntuneWinAppUtil.exe -c <setup_folder> -s <setup_file> -o <output_folder>
    $Args = "-c `"$FullSource`" -s `"$SetupFile`" -o `"$FullOutput`" -q"
    
    try {
        $Process = Start-Process -FilePath $ExePath -ArgumentList $Args -Wait -NoNewWindow -PassThru -ErrorAction Stop
        if ($Process.ExitCode -eq 0) {
            Write-Verbose "Successfully created .intunewin package in '$FullOutput'."
            return $true
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
