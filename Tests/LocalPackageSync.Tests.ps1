$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
$ScriptToTest = "$ProjectRoot\Invoke-LocalPackageSync.ps1"

Describe "Invoke-LocalPackageSync" {
    It "Throws an error if the source path does not exist" {
        { & $ScriptToTest -AppName "TestApp" -Vendor "TestVendor" -Version "1.0.0" -SourcePath "C:\NonExistent.exe" } | Should -Throw
    }

    It "Throws an error if mandatory parameters are missing" {
        { & $ScriptToTest -SourcePath "C:\Existing.exe" } | Should -Throw
    }
}
