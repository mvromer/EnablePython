[CmdletBinding()]
param()

Get-Module
Install-Module -Name Psake
Install-Module -Name Pester -Force -SkipPublisherCheck
