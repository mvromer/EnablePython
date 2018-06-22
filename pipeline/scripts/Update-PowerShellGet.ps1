[CmdletBinding()]
param()

$ErrorActionPreferenc = "Stop"

# Update to the latest PowerShellGet so that we have prerelease support and make sure we have that module loaded. This
# needs to be a separate step (at least for now) because 1.6.5 of PSGet has a bug that causes subsequent package
# installations to fail even if we reload PSGet after install. The error we get is the following:
#
# Install-Package : A parameter cannot be found that matches parameter name 'AllowPrereleaseVersions'.
#
# This is apparently fixed in a recent commit to PSGet, but it hasn't been released yet.
#
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name PowerShellGet -Force
