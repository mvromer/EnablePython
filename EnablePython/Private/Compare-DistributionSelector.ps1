<#
.SYNOPSIS
Checks to see if the reference selector matches the given difference selector. Read the description to see what
constitutes a match.

.DESCRIPTION
All comparisons are done in a case-insensitive manner. The rules for matching are as follows:

  1. If the reference and difference selectors are equal, then the result is true. This is an exact match.
  2. If the difference selector is a prefix of the reference selector, then the result is true. This is a prefix match.
  3. If the reference selector is "like" the difference selector (as determined by the -like operator), then the result
     is true. This is a wildcard match.
  4. In all other cases, the result is false.

.PARAMETER Reference
The selector against which the difference selector is compared.

.PARAMETER Difference
The selector to compare against the reference selector. This may contain wildcard characters.

.EXAMPLE
Perform an exact match.

Compare-DistributionSelector -Reference PythonCore -Difference PythonCore
$true

.EXAMPLE
Perform a prefix match.

Compare-DistributionSelector -Reference 3.6.3 -Difference 3.6
$true

.EXAMPLE
Perform a wildcard match.

Compare-DistributionSelector -Reference Continuum -Difference "Cont*"
$true

#>
function Compare-DistributionSelector {
	[CmdletBinding()]
	param(
		[Parameter( Mandatory )]
		[string] $Reference,

		[Parameter( Mandatory )]
		[string] $Difference
	)

	# First check for exact match. This always trumps everything.
	if( $Reference -eq $Difference ) {
		return $true
	}

	# Now do a prefix match. This is likely the most common type of fuzzy match we'll expect. For example, someone may
	# say they want to enable version 3.6, which will match version 3.6.3.
	if( $Reference.StartsWith( $Difference, [System.StringComparison]::OrdinalIgnoreCase ) ) {
		return $true
	}

	# Lastly we support wildcard matching.
	if( $Reference -like $Difference ) {
		return $true
	}

	$false
}
