<#
.SYNOPSIS
Gets information on all registered Python distributions installed on the current system.

.DESCRIPTION
According to PEP 514 (https://www.python.org/dev/peps/pep-0514/), Python distributions are to register themselves on
Windows using well-defined registry locations. Distributions can either be installed in a system-wide location or in a
user-specific location.

Within a given scope, distributions are differentiated by a pair of values denoting what PEP 514 refers to as the
distribution's company and the tag. Each distribution can also be 32- or 64-bit.

These identifying pieces of information can be used to discover which Python distributions are available to the user on
the current system. They can also be used to filter the list of available distributions, which is useful for eventually
enabling a particular distribution within the current session.

When no arguments are given, information on all registered Python distributions with a valid installation are returned.
The values returned can then be passed to Enable-Python to enable a specific distribution. Passing additional arguments
will filter the list of returned distributions based on the filtered properties.

A filter on a distribution property will match a distribution if any of the following conditions are met:

  1. The distribution's property matches exactly the filtered value.
  2. The distribution's property is prefixed by the filtered value.
  3. The distribution's property is "like" the filtered value (according to the rules of the -like operator). This means
     the filtered value can contain wildcard characters.

All comparisons and checks are done in a case-insensitive manner.

.PARAMETER Company
Returns distributions whose company matches the given value.

.PARAMETER Tag
Returns distributions whose tag matches the given value.

.PARAMETER Version
Returns distributions whose version matches the given value. This can also be set to "latest", which causes only the
most recent version of those distributions matching the other filter criteria to be returned.

.PARAMETER Bitness
Returns distributions whose bitness matches the given value.

.PARAMETER Scope
Returns distributions whose scope matches the given value.

#>
function Get-PythonDistribution {
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
		[ValidateSet( "System", "CurrentUser" )]
		[string] $Scope
	)

	$ErrorActionPreference = "Stop"

	$distributions = @()
	$distributionSets = @(
		@{
			RegKeyPrefix = "HKLM:\SOFTWARE\Python"
			Scope = "System"
		},

		@{
			RegKeyPrefix = "HKLM:\SOFTWARE\WOW6432Node\Python"
			Scope = "System"
		}

		@{
			RegKeyPrefix = "HKCU:\Software\Python"
			Scope = "CurrentUser"
		}
	)

	foreach( $distributionSet in $distributionSets ) {
		if( -not $Scope -or $distributionSet.Scope -eq $Scope ) {
			foreach( $companyKey in (Get-ChildItem -Path $distributionSet.RegKeyPrefix -ErrorAction Ignore) ) {
				if( -not $Company -or (Compare-DistributionSelector $companyKey.PSChildName $Company) ) {
					foreach( $tagKey in (Get-ChildItem -Path $companyKey.PSPath) ) {
						if( -not $Tag -or (Compare-DistributionSelector $tagKey.PSChildName $Tag) ) {
							$installPathKey = Get-Item -Path "$($tagKey.PSPath)\InstallPath" -ErrorAction Ignore
							if( $installPathKey ) {
								$installPath = Get-ItemPropertyValue -Path $installPathKey.PSPath -Name "(Default)"

								# If we can't get the distribution version or bitness, this is usually because there is
								# no Python interpreter installed at the given install path. This would typically happen
								# if a distribution doesn't properly clean out its registry keys whenever it is removed.
								$distributionVersion = Get-DistributionVersion -InstallPath $installPath
								if( -not $distributionVersion ) {
									Write-Warning ("Cannot determine distribution version. Skipping distribution " +
										"located at install path $installPath (Company=$($companyKey.PSChildName), " +
										"Tag=$($tagKey.PSChildName), Scope=$($distributionSet.Scope)).")
									continue
								}

								if( $Version -and $Version -ne "latest" -and
									-not (Compare-DistributionSelector $distributionVersion $Version) ) {
									continue
								}

								$distributionBitness = Get-DistributionBitness -InstallPath $installPath
								if( -not $distributionBitness ) {
									Write-Warning ("Cannot determine distribution bitness. Skipping distribution " +
										"located at install path $installPath (Company=$($companyKey.PSChildName), " +
										"Tag=$($tagKey.PSChildName), Scope=$($distributionSet.Scope)).")
									continue
								}

								if( $Bitness -and -not (Compare-DistributionSelector $distributionBitness $Bitness) ) {
									continue
								}

								$distributions += [PSCustomObject]@{
									Company = $companyKey.PSChildName
									Tag = $tagKey.PSChildName
									Version = $distributionVersion
									Bitness = $distributionBitness
									Scope = $distributionSet.Scope
									InstallPath = $installPath
								}
							}
						}
					}
				}
			}
		}
	}

	if( $Version -eq "latest" ) {
		$latestVersion = $distributions | `
			% { [System.Version]$_.Version } | `
			Measure-Object -Maximum | `
			Select-Object -ExpandProperty Maximum

		$distributions = $distributions | ? { $_.Version -eq $latestVersion }
	}

	$distributions
}
