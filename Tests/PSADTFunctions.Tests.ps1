$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
$ScriptToTest = "$ProjectRoot\Scripts\PSADTFunctions.ps1"

# Import the script to test
. $ScriptToTest

Describe "Set-PSADTInstallCommand" {
    $TempPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [guid]::NewGuid().ToString())
    $ScriptFile = [System.IO.Path]::Combine($TempPath, "Invoke-AppDeployToolkit.ps1")
    $Placeholder = "## <Perform Installation tasks here>"

    BeforeAll {
        New-Item -ItemType Directory -Path $TempPath -Force | Out-Null
    }

    AfterAll {
        Remove-Item -Path $TempPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    BeforeEach {
        $InitialContent = @"
# Some header content
$Placeholder
# Some footer content
"@
        $InitialContent | Out-File -FilePath $ScriptFile -Encoding utf8 -Force
    }

    It "Replaces {InstallerName} placeholder in CustomCommand with actual InstallerName" {
        $CustomCommand = 'Start-ADTProcess -FilePath "$PSScriptRoot\Files\{InstallerName}" -Arguments "/S"'
        $InstallerName = "MyInstaller_v1.0.exe"
        
        $Result = Set-PSADTInstallCommand -PackagePath $TempPath -InstallerName $InstallerName -CustomCommand $CustomCommand
        
        $Result | Should -Be $true
        $UpdatedContent = Get-Content -Path $ScriptFile -Raw
        $ExpectedCommand = "`tStart-ADTProcess -FilePath "`$PSScriptRoot\Files\MyInstaller_v1.0.exe" -Arguments "/S""
        $UpdatedContent | Should -Contain $ExpectedCommand
    }

    It "Uses default MSI command when no CustomCommand is provided and extension is .msi" {
        $InstallerName = "App.msi"
        
        $Result = Set-PSADTInstallCommand -PackagePath $TempPath -InstallerName $InstallerName
        
        $Result | Should -Be $true
        $UpdatedContent = Get-Content -Path $ScriptFile -Raw
        $ExpectedCommand = "`tStart-ADTMsiProcess -FilePath "`$PSScriptRoot\Files\App.msi" -Action Install"
        $UpdatedContent | Should -Contain $ExpectedCommand
    }

    It "Uses default EXE command when no CustomCommand is provided and extension is .exe" {
        $InstallerName = "App.exe"
        
        $Result = Set-PSADTInstallCommand -PackagePath $TempPath -InstallerName $InstallerName
        
        $Result | Should -Be $true
        $UpdatedContent = Get-Content -Path $ScriptFile -Raw
        $ExpectedCommand = "`tStart-ADTProcess -FilePath "`$PSScriptRoot\Files\App.exe" -Arguments "/silent /norestart""
        $UpdatedContent | Should -Contain $ExpectedCommand
    }
}
