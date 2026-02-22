$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
$LibraryFunctions = "$ProjectRoot\Scripts\LibraryFunctions.ps1"

# Dot-source the library functions
. $LibraryFunctions

Describe "Sync-EvergreenLibraryApp" {
    Context "DataPath Redirection" {
        It "Uses LibraryPath for Installers by default when DataPath is not provided" {
            # This test might fail if the function is updated to require DataPath, 
            # or it will verify the current (default) behavior.
            # We need to mock Get-LatestEvergreenAppVersion to return a dummy app
            Mock Get-LatestEvergreenAppVersion {
                return [PSCustomObject]@{
                    Version = "1.0.0"
                    Architecture = "x64"
                    Channel = "Stable"
                    URI = "http://example.com/installer.exe"
                }
            }
            # Mock Save-EvergreenApp (from Evergreen module)
            Mock Save-EvergreenApp {
                return [PSCustomObject]@{
                    FullName = "C:\Evergreen\Installers\Vendor\App\Stable\1.0.0\x64\installer.exe"
                }
            }

            $AppConfig = [PSCustomObject]@{
                Name = "App"
                Vendor = "Vendor"
                EvergreenApp = "App"
            }

            # We assume for now it only takes LibraryPath
            $Result = Sync-EvergreenLibraryApp -AppConfig $AppConfig -LibraryPath "C:\Evergreen"
            
            # Verify the mock was called with the correct path
            Assert-MockCalled Save-EvergreenApp -ParameterFilter { $Path -eq "C:\Evergreen\Installers\Vendor\App" }
        }

        It "Uses DataPath for Installers when provided" {
            # This is the NEW requirement. This test should fail until we update the script.
            Mock Get-LatestEvergreenAppVersion {
                return [PSCustomObject]@{
                    Version = "1.0.0"
                    Architecture = "x64"
                    Channel = "Stable"
                    URI = "http://example.com/installer.exe"
                }
            }
            Mock Save-EvergreenApp {
                return [PSCustomObject]@{
                    FullName = "\Server\Share\Installers\Vendor\App\Stable\1.0.0\x64\installer.exe"
                }
            }

            $AppConfig = [PSCustomObject]@{
                Name = "App"
                Vendor = "Vendor"
                EvergreenApp = "App"
            }

            # EXPECTATION: We add a DataPath parameter
            $Result = Sync-EvergreenLibraryApp -AppConfig $AppConfig -LibraryPath "C:\Evergreen" -DataPath "\Server\Share"
            
            Assert-MockCalled Save-EvergreenApp -ParameterFilter { $Path -eq "\Server\Share\Installers\Vendor\App" }
        }
    }
}
