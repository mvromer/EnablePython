[CmdletBinding()]
param(
    [Parameter( Mandatory )]
    [string] $ProjectRoot,

    [Parameter( Mandatory )]
    [string] $ModuleName,

    [Parameter( Mandatory )]
    [uri] $TestResultsEndpoint
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $ProjectRoot "build\$ModuleName"
$testDir = Join-Path $ProjectRoot Tests
$testResultsFileName = Join-Path $testDir "$ModuleName-test-results.xml"

$webclient = New-Object System.Net.WebClient
$webclient.UploadFile( $TestResultsEndpoint, $testResultsFileName ) | Out-Null

# Signal build failure if there is at least one error in our test results.
$results = [xml](Get-Content -Path $testResultsFileName)
$numberFailed = $results.'test-results'.failures
if( $numberFailed -ne 0 ) {
    throw "$numberFailed test(s) failed."
}
