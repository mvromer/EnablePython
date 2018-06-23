[CmdletBinding()]
param(
    [Parameter( Mandatory )]
    [string] $ProjectRoot,

    [Parameter( Mandatory )]
    [string] $ModuleName,

    [Parameter( Mandatory )]
    [string] $BaseVersionNumber,

    [Parameter()]
    [string] $PrereleaseTag
)

$ErrorActionPreference = "Stop"

# Recreate any build directory we might have so we start from a pristine state.
$buildDir = Join-Path $ProjectRoot "build"
Remove-Item -Path $buildDir -Force -Recurse -ErrorAction Ignore
New-Item -Path $buildDir -ItemType Directory | Out-Null

# Create a new module directory in our build output and copy over the manifest file.
$sourceModuleDir = Join-Path $ProjectRoot $ModuleName
$destModuleDir = Join-Path $buildDir $ModuleName
$manifestFileName = "$ModuleName.psd1"
$sourceManifest = Join-Path $sourceModuleDir $manifestFileName
$destManifest = Join-Path $destModuleDir $manifestFileName

New-Item -Path $destModuleDir -ItemType Directory | Out-Null
Copy-Item $sourceManifest $destManifest

# Gather the names of our public and private functions that we want to merge into our destination.
$publicFunctions = Get-ChildItem -Path (Join-Path $sourceModuleDir Public) -Filter *.ps1 -Recurse
$privateFunctions = Get-ChildItem -Path (Join-Path $sourceModuleDir Private) -Filter *.ps1 -Recurse
$allFunctions = $publicFunctions + $privateFunctions

# Merge our public and private functions into our destination's root module file.
$rootModuleFileName = "$ModuleName.psm1"
$destRootModule = Join-Path $destModuleDir $rootModuleFileName
foreach( $function in $allFunctions ) {
    Get-Content -Path $function.FullName | Add-Content -Path $destRootModule
}

# Gather the list of publicly exported aliases.
$publicAliases = $publicFunctions | % {
    . $_.FullName
    Get-Alias -Definition $_.BaseName -ErrorAction Ignore | Select-Object -ExpandProperty Name
}

# Update version information and exported items in the module's manifest.
$updateArgs = @{
    ModuleVersion = $BaseVersionNumber
    FunctionsToExport = $publicFunctions | % { $_.BaseName }
}

if( $AliasesToExport ) {
    $updateArgs.AliasesToExport = $publicAliases
}

if( $PrereleaseTag ) {
    $updateArgs.Prerelease = $PrereleaseTag
}

Update-ModuleManifest -Path $destManifest @updateArgs
