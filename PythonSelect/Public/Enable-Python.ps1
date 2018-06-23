<#
.SYNOPSIS
Makes the specified Python distribution the active one for the current session.

.DESCRIPTION
A Python distribution is considered "active" when its installation and script locations are both in the current PATH
environment variable and are not shadowed by another distribution. When a Python distribution is enabled, the PATH is
scrubbed of any references to any other Python distribution. Then the selected distribution's installation and script
locations are appended to the PATH.

The environment changes remain active only for the current session. Once a distribution has been enabled, references in
the PATH to Python locations should NOT be added, removed, or modified. This may interfere with future attempts to
enable different Python environments within the same session.

Parameters can be given to select the distribution that should be enabled. These parameters behave exactly like those
passed to Get-PythonDistribution. See the help for Get-PythonDistribution for more information. If no parameters are
given, then this will attempt to enable the latest version of the official Python distribution found on the system.

If no distributions are found matching the given parameters or multiple distributions are found, then this will fail.

.PARAMETER Company
Selects and activates a distribution whose company matches the given value.

.PARAMETER Tag
Selects and activates a distribution whose tag matches the given value.

.PARAMETER Version
Selects and activates a distribution whose version matches the given value. This can also be set to "latest", which
causes only the most recent version of those distributions matching the other filter criteria to be activated.

.PARAMETER Bitness
Selects and activates a distribution whose bitness matches the given value.

.PARAMETER Scope
Selects and activates a distribution whose scope matches the given value.

#>
function Enable-Python {
	[CmdletBinding()]
	param(
		[Parameter()]
		[string] $Company,

		[Parameter()]
		[string] $Tag,

		[Parameter()]
		[string] $Version,

		[Parameter()]
		[ValidateSet( "32", "64" )]
		[string] $Bitness,

		[Parameter()]
		[ValidateSet( "System" , "CurrentUser" )]
		[string] $Scope
	)

	$ErrorActionPreference = "Stop"

	# If no selection criteria is given, we'll try to select the latest version of the standard Python distribution.
	if( -not $Company -and -not $Tag -and -not $Version ) {
		Write-Host "No distribution information given. Searching for latest version of the standard Python distribution."
		$Company = "PythonCore"
		$Version = "latest"

		# If no bitness was selected, then we'll try to select the one whose bitness matches the current environment.
		if( -not $Bitness ) {
			$Bitness = if( [System.Environment]::Is64BitProcess ) { "64" } else { "32" }
		}

		# Unless the user is requesting a specific scope, then make sure we search the system scope.
		if( -not $Scope ) {
			$Scope = "System"
		}
	}

	$getArgs = @{}
	if( $Company ) { $getArgs.Company = $Company }
	if( $Tag ) { $getArgs.Tag = $Tag }
	if( $Version ) { $getArgs.Version = $Version }
	if( $Bitness ) { $getArgs.Bitness = $Bitness }
	if( $Scope ) { $getArgs.Scope = $Scope }

	$distributions = Get-PythonDistribution @getArgs
	if( $distributions.Count -eq 0 ) {
		Write-Host "No Python distributions found matching given distribution information."
		throw "Failed to enable Python distribution. No distributions found."
	}

	if( $distributions.Count -gt 1 ) {
		Write-Host "Multiple Python distributions found matching given distribution information:"
		$distributions | Format-Table -Property Company,Tag,Version,Bitness,Scope | Out-Host
		throw "Failed to enable Python distribution. Ambiguous selection."
	}

	# If this is the first invocation of this cmdlet, wipe any Python paths the user may have previously had set.
	if( -not $global:EnablePythonAlreadySet ) {
		Get-PythonDistribution | Clear-PythonInstallPath
		$global:EnablePythonAlreadySet = $true
	}

	$distribution = $distributions[0]
	Write-Host "Python distribution found in $($distribution.InstallPath). Updating PATH."

	if( $global:EnablePythonInstallPath ) {
		Clear-PythonInstallPath -InstallPath $global:EnablePythonInstallPath
	}

	$environmentPaths = $env:Path.Split( [System.IO.Path]::PathSeparator, [System.StringSplitOptions]::None )
	$environmentPaths += @( $distribution.InstallPath, (Join-Path $distribution.InstallPath "Scripts") )
	$env:Path = [string]::Join( [System.IO.Path]::PathSeparator, $environmentPaths )
	$global:EnablePythonInstallPath = $distribution.InstallPath
}
