[CmdletBinding()]
param()

# According to https://github.com/PowerShell/PowerShellGet/issues/246#issuecomment-376346105, to update PSGet in an
# automated build, we should do the update in a separate PowerShell session.
powershell.exe -Command { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted }
powershell.exe -Command { Install-Module -Name PowerShellGet -Force }
Install-Module -Name Psake
Install-Module -Name Pester -Force -SkipPublisherCheck
