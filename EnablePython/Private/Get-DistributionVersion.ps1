<#
.SYNOPSIS
Gets the version of the Python interpreter installed at the given install location in major.minor.micro format.

.PARAMETER InstallPath
Root directory of the Python distribution to check.

#>
function Get-DistributionVersion {
	[CmdletBinding()]
	param(
		[Parameter( Mandatory )]
		[string] $InstallPath
	)

	$python = Get-Command (Join-Path $InstallPath "python.exe")
	& $python -c "import sys; print( '%d.%d.%d' % (sys.version_info.major, sys.version_info.minor, sys.version_info.micro) )"
}
