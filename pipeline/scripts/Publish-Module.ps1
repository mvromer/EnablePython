[CmdletBinding()]
param(
    [Parameter( Mandatory )]
    [string] $ProjectRoot,

    [Parameter( Mandatory )]
    [string] $ModuleName,

    [Parameter( Mandatory )]
    [string] $NugetApiKey
)

$ErrorActionPreference = "Stop"
$modulePath = Join-Path $ProjectRoot "build\$ModuleName"
Publish-Module -Path $modulePath -NugetApiKey $NugetApiKey
