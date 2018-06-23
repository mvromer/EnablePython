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

	$python = Get-Python -InstallPath $InstallPath
	if( $python ) {
        # Older versions of Python don't have support for the tuple field names major, minor, and micro. Instead, we
        # access the version info fields by their respective indexes.
		& $python -c "import sys; print( '%d.%d.%d' % (sys.version_info[0], sys.version_info[1], sys.version_info[2]) )"
	}
}
