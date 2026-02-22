$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
$LibraryFunctions = "$ProjectRoot\Scripts\LibraryFunctions.ps1"

# Dot-source the library functions
. $LibraryFunctions

Describe "Write-SpruceLog" {
    $TestLogDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [guid]::NewGuid().ToString())
    $TextLogFile = [System.IO.Path]::Combine($TestLogDir, "SpruceUp.log")
    $CsvLogFile = [System.IO.Path]::Combine($TestLogDir, "SyncSummary.csv")

    BeforeAll {
        New-Item -ItemType Directory -Path $TestLogDir -Force | Out-Null
    }

    AfterAll {
        Remove-Item -Path $TestLogDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    It "Creates and writes to a text log file" {
        $Message = "Testing text log"
        Write-SpruceLog -Message $Message -LogFile $TextLogFile -Level "INFO"
        
        Test-Path $TextLogFile | Should -Be $true
        $Content = Get-Content $TextLogFile -Raw
        $Content | Should -Match "\[.*\] \[INFO\] Testing text log"
    }

    It "Writes to CSV file only when Summary object is provided" {
        $Summary = @{
            AppName = "TestApp"
            Version = "1.0.0"
            Status  = "Success"
            Path    = "C:\Temp"
        }
        
        Write-SpruceLog -Message "Summary test" -LogFile $TextLogFile -CsvFile $CsvLogFile -Summary $Summary
        
        Test-Path $CsvLogFile | Should -Be $true
        $CsvContent = Import-Csv $CsvLogFile
        $CsvContent.AppName | Should -Be "TestApp"
        $CsvContent.Status | Should -Be "Success"
    }

    It "Includes AppName in text log if provided" {
        $Message = "App specific message"
        Write-SpruceLog -Message $Message -LogFile $TextLogFile -AppName "GoogleChrome"
        
        $Content = Get-Content $TextLogFile -Tail 1
        $Content | Should -Match "\[GoogleChrome\] App specific message"
    }
}
