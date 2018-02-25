<#
.SYNOPSIS
Gets whether the Python interpreter installed at the given install location is 32- or 64-bit.

.PARAMETER InstallPath
Root directory of the Python distribution to check.

#>
function Get-DistributionBitness {
	[CmdletBinding()]
	param(
		[Parameter( Mandatory )]
		[string] $InstallPath
	)

	$python = Get-Command (Join-Path $InstallPath "python.exe")
	& $python -c "import struct; print( 8 * struct.calcsize( 'P' ) )"
}
