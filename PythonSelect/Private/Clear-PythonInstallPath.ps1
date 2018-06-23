<#
.SYNOPSIS
Removes traces of the given installation location to a particular Python distribution from the user's PATH.

.DESCRIPTION
This searches for the given installation location as well as $InstallPath\Scripts in the user's PATH environment
variable. If either are found, then they are removed. These changes do not persist beyond the current session in which
they are made.

.PARAMETER InstallPath
Root directory of the Python distribution to search for in the user's PATH.

#>
function Clear-PythonInstallPath {
	[CmdletBinding()]
	param(
		[Parameter( Mandatory, ValueFromPipelineByPropertyName )]
		[string[]] $InstallPath
	)

	begin {
		$environmentPaths = $env:Path.Split( [System.IO.Path]::PathSeparator, [System.StringSplitOptions]::None )
		$normalizedEnvironmentPaths = $environmentPaths | % { if( $_ ) { Get-NormalizedPath -Path $_ } else { "" } }
		$pathsToRemove = @()
	}

	process {
		foreach( $path in $InstallPath ) {
			$pythonPath = Get-NormalizedPath -Path $path
			$scriptsPath = Get-NormalizedPath -Path (Join-Path $path "Scripts")

			for( $iEnvPath = 0; $iEnvPath -lt $environmentPaths.Count; $iEnvPath++ ) {
				if( $pythonPath -eq $normalizedEnvironmentPaths[$iEnvPath] -or
					$scriptsPath -eq $normalizedEnvironmentPaths[$iEnvPath] ) {
					$pathsToRemove += $environmentPaths[$iEnvPath]
				}
			}
		}
	}

	end {
		$environmentPaths = $environmentPaths | ? { $pathsToRemove -notcontains $_ }
		$env:Path = [string]::Join( [System.IO.Path]::PathSeparator, $environmentPaths )
	}
}
