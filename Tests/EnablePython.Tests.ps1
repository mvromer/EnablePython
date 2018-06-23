[CmdletBinding()]
param(
    [Parameter()]
    [string] $ModulePath = "$PSScriptRoot\..\EnablePython"
)

Import-Module $ModulePath -Force
. $PSScriptRoot\Mocks.ps1

Describe "Get-PythonDistribution" {
    Context "Unit Tests" {
        Mock-Registry

        It "Gets the latest version" {
            $distributions = Get-PythonDistribution -Version latest
            $distributions | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
            $distributions | % { $_.Version | Should -Be "3.6" }
        }

        It "Gets all distributions with same specified version" {
            $distributions = Get-PythonDistribution -Version "2.7"
            $distributions | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 2
            $distributions | % { $_.Version | Should -Be "2.7" }
        }

        It "Gets all distributions matching the partially specified version" {
            $distributions = Get-PythonDistribution -Version "3"
            $distributions | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 2
            $distributions.Version | Should -Be @("3.6", "3.3")
        }

        It "Gets all distributions for a company" {
            $distributions = Get-PythonDistribution -Company "MyPythonCore"
            $distributions | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 4
            $distributions | % { $_.Company | Should -Be "MyPythonCore" }
        }

        It "Gets all distributions wildcard matching the partially specified company" {
            $distributions = Get-PythonDistribution -Company "*Core"
            $distributions | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 4
            $distributions | % { $_.Company | Should -Be "MyPythonCore" }
        }

        It "Gets all distributions for a tag" {
            $distributions = Get-PythonDistribution -Tag "2.7"
            $distributions | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 2
            $distributions | % { $_.Tag | Should -Be "2.7" }
        }

        It "Gets all distributions with a certain bitness" {
            $distributions = Get-PythonDistribution -Bitness 32
            $distributions | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
            $distributions | % { $_.Bitness | Should -Be 32 }
        }

        It "Gets all distributions for a specific scope" {
            $distributions = Get-PythonDistribution -Scope CurrentUser
            $distributions | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
            $distributions | % { $_.Scope | Should -Be "CurrentUser" }
        }
    }

    Context "Integration Tests" {
        $script:CachedPath = $null

        BeforeEach {
            $script:CachedPath = $env:Path
            New-Item -Path "HKCU:\Software\Python\MyPythonCore\3.3\InstallPath" -Force | Out-Null
            Set-Item -Path "HKCU:\Software\Python\MyPythonCore\3.3\InstallPath" -Value "C:\Users\Me\AppData\MyPython3.3"
        }

        AfterEach {
            $env:Path = $script:CachedPath
            Remove-Item -Path "HKCU:\Software\Python\MyPythonCore" -Recurse
        }

        It "Does not crash if registry has stale distribution entry" {
            { Get-PythonDistribution } | Should -Not -Throw
        }
    }
}

Describe "Enable-Python" {
    Context "Unit Tests" {
        Mock-Registry

        $script:CachedPath = $null

        BeforeEach {
            $script:CachedPath = $env:Path
        }

        AfterEach {
            $env:Path = $script:CachedPath
        }

        It "Enables latest system version" {
            { Enable-Python -Version latest -Scope System | Out-Null } | Should -Not -Throw
            "C:\MyPython3.6" | Should -BeIn $env:Path.Split( ";" )
        }

        It "Enables the distribution for the specific company, tag, and bitness" {
            { Enable-Python -Company "MyPythonCore" -Tag "2.7" -Bitness 64 } | Should -Not -Throw
            "C:\MyPython2.7" | Should -BeIn $env:Path.Split( ";" )
        }

        It "Fails when no distribution can be found" {
            { Enable-Python -Company "DoesNotExist" } | Should -Throw
        }

        It "Fails when multiple distributions are found" {
            { Enable-Python -Version "3" } | Should -Throw
        }
    }

    Context "Integration Tests" {
        $script:CachedPath = $null

        BeforeEach {
            $script:CachedPath = $env:Path
        }

        AfterEach {
            $env:Path = $script:CachedPath
        }

        It "Enables the latest system version by default" {
            { Enable-Python } | Should -Not -Throw
            python.exe -c "import sys; print( 'Hello from Python' )" | Should -Be "Hello from Python"
        }

        It "Does not hose already set distribution if subsequent distribution fails" {
            { Enable-Python } | Should -Not -Throw
            python.exe -c "import sys; print( 'Hello from Python' )" | Should -Be "Hello from Python"
            { Enable-Python -Version "2.9" } | Should -Throw
            python.exe -c "import sys; print( 'Hello from Python again' )" | Should -Be "Hello from Python again"
        }
    }
}
