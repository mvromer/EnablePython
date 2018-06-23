[CmdletBinding()]
param(
    [Parameter( Mandatory )]
    [string] $ProjectRoot,

    [Parameter( Mandatory )]
    [string] $ModuleName
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $ProjectRoot "build\$ModuleName"
$testDir = Join-Path $ProjectRoot Tests
$testResultsFileName = Join-Path $testDir "$ModuleName-test-results.xml"

# Sometimes when testing locally there might be another version of our module loaded, but when the tests run and try to
# import the version under test, they'll fail and report a conflict. So we attempt to unload any modules with the same
# name prior to invoking our tests.
Remove-Module -Name $ModuleName -ErrorAction Ignore

Invoke-Pester -OutputFile $testResultsFileName -OutputFormat NUnitXML -Script @{
    Path = $testDir
    Parameters = @{
        ModulePath = $modulePath
    }
}
