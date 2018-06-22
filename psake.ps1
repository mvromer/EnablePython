[CmdletBinding()]
param(
    [Parameter( Mandatory, Position = 0 )]
    [string] $TaskName,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $ProjectRoot = $PSScriptRoot,

    [Parameter()]
    [string] $ModuleName = "EnablePython",

    [Parameter()]
    [string] $BaseVersionNumber = $env:BASE_VERSION_NUMBER,

    [Parameter()]
    [string] $PrereleaseTag = $env:PRERELEASE_TAG
)

$ErrorActionPreference = "Stop"

# Capture all parameters, bound or defaulted, that aren't the task name. These will be passed as build parameters to our
# PSake build script.
$buildParams = @{}
$allParams = $PSCmdlet.MyInvocation.MyCommand.Parameters
$commonParameters = @( "Debug", "ErrorAction", "ErrorVariable", "InformationAction", "InformationVariable",
    "OutVariable", "OutBuffer", "PipelineVariable", "Verbose", "WarningAction", "WarningVariable" )

foreach( $paramName in $allParams.Keys ) {
    # Skip the TaskName parameter and all common cmdlet parameters.
    if( $paramName -eq "TaskName" -or $commonParameters -contains $paramName ) {
        continue
    }

    if( $PSBoundParameters.ContainsKey( $paramName ) ) {
        # Get the value explicitly given to this script.
        $paramValue = $PSBoundParameters[$paramName]
    }
    else {
        # Get the parameter's defaulted value (if any).
        $paramValue = Get-Variable -Name $paramName -ValueOnly -ErrorAction Ignore
    }

    # Only add parameters that have values defined.
    if( $paramValue ) {
        $buildParams[$paramName] = $paramValue
    }
}

Push-Location $ProjectRoot
try {
    Import-Module psake
    Invoke-psake -BuildFile $ProjectRoot\pipeline\psakefile.ps1 `
        -TaskList $TaskName `
        -parameters $buildParams `
        -nologo `
        -notr

    if( -not $psake.build_success ) {
        throw "Task $TaskName failed."
    }
}
finally {
    Pop-Location
}
