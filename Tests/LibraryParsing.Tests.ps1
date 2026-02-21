$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
$ScriptToTest = "$ProjectRoot\Scripts\LibraryFunctions.ps1"

Describe "Get-EvergreenLibraryApps" {
    It "Throws an error if the manifest file does not exist" {
        { Get-EvergreenLibraryApps -Path "non-existent.json" } | Should -Throw
    }

    It "Returns an array of application objects from a valid manifest" {
        $TempFile = [System.IO.Path]::GetTempFileName()
        $Manifest = @(
            @{ Name = "GoogleChrome"; Publisher = "Google" },
            @{ Name = "MicrosoftEdge"; Publisher = "Microsoft" }
        )
        $Manifest | ConvertTo-Json | Out-File $TempFile -Encoding utf8

        try {
            $Apps = Get-EvergreenLibraryApps -Path $TempFile
            $Apps.Count | Should -Be 2
            $Apps[0].Name | Should -Be "GoogleChrome"
        }
        finally {
            Remove-Item $TempFile -ErrorAction SilentlyContinue
        }
    }
}
