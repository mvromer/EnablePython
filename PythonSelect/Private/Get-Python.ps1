<#
.SYNOPSIS
Gets the Python executable installed at the given installation location.

.PARAMETER InstallPath
Root directory of the Python distribution to get the executable from.

#>
function Get-Python {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory )]
        [string] $InstallPath
    )

    Get-Command (Join-Path $InstallPath "python.exe") -ErrorAction Ignore
}
