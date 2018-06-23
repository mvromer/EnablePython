<#
.SYNOPSIS
"Normalizes" a path by ensuring it has exactly one trailing slash.

.DESCRIPTION
This is used to make directory path comparisons easier in, e.g,. Clear-PythonInstallPath.

.PARAMETER Path
The path to normalize.

#>
function Get-NormalizedPath {
	[CmdletBinding()]
	param(
		[Parameter( Mandatory )]
		[string] $Path
	)

	# This is kind of hacky, but it's a way to ensure all the PATH items we care about have a trailing slash for easier
	# install path comparison.
	Join-Path $Path ""
}
