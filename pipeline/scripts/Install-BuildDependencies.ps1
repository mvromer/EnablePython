[CmdletBinding()]
param()

$ErrorActionPreferenc = "Stop"

# Update to the latest PowerShellGet so that we have prerelease support and make sure we have that module loaded.
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name PowerShellGet -Force
Remove-Module -Name PowerShellGet -Force
Import-Module -Name PowerShellGet

# Install the rest of our build dependencies.
Install-Module -Name Psake
Install-Module -Name Pester -Force -SkipPublisherCheck
