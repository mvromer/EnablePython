[CmdletBinding()]
param()

$ErrorActionPreferenc = "Stop"

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name Psake
Install-Module -Name Pester
