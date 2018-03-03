# Mock out the following Python distributions based on how they would be defined in the registry.
#
#   Scope: System
#     Bitness 64
#       Company: MyPythonCore
#         Tag: 3.6
#           Install Path: C:\MyPython3.6
#         Tag: 2.7
#           Install Path: C:\MyPython2.7
#     Bitness: 32
#       Company: MyPythonCore
#         Tag: 2.7
#           Install Path: C:\MyPython2.7-x86
#   User Scope
#     Bitness 64
#       Company: MyPythonCore
#         Tag: 3.3
#           Install Path: C:\Users\Me\AppData\MyPython3.3

function Mock-Registry {
    # Get-ChildItem mocks. These retrieve the Company and Tag for a distribution.
    Mock Get-ChildItem -ModuleName EnablePython -MockWith {
        return [PSCustomObject]@{
            PSChildName = "MyPythonCore"
            PSPath = "HKLM:\SOFTWARE\Python\MyPythonCore"
        }
    } -ParameterFilter {
        $Path -and $Path -eq "HKLM:\SOFTWARE\Python"
    }

    Mock Get-ChildItem -ModuleName EnablePython -MockWith {
        return [PSCustomObject]@{
            PSChildName = "MyPythonCore"
            PSPath = "HKLM:\SOFTWARE\WOW6432Node\Python\MyPythonCore"
        }
    } -ParameterFilter {
        $Path -and $Path -eq "HKLM:\SOFTWARE\WOW6432Node\Python"
    }

    Mock Get-ChildItem -ModuleName EnablePython -MockWith {
        return [PSCustomObject]@{
            PSChildName = "MyPythonCore"
            PSPath = "HKCU:\SOFTWARE\Python\MyPythonCore"
        }
    } -ParameterFilter {
        $Path -and $Path -eq "HKCU:\SOFTWARE\Python"
    }

    Mock Get-ChildItem -ModuleName EnablePython -MockWith {
        return @(
            [PSCustomObject]@{
                PSChildName = "3.6"
                PSPath = "HKLM:\SOFTWARE\Python\MyPythonCore\3.6"
            },
            [PSCustomObject]@{
                PSChildName = "2.7"
                PSPath = "HKLM:\SOFTWARE\Python\MyPythonCore\2.7"
            } )
    } -ParameterFilter {
        $Path -and $Path -eq "HKLM:\SOFTWARE\Python\MyPythonCore"
    }

    Mock Get-ChildItem -ModuleName EnablePython -MockWith {
        return @(
            [PSCustomObject]@{
                PSChildName = "2.7"
                PSPath = "HKLM:\SOFTWARE\WOW6432Node\Python\MyPythonCore\2.7"
            } )
    } -ParameterFilter {
        $Path -and $Path -eq "HKLM:\SOFTWARE\WOW6432Node\Python\MyPythonCore"
    }

    Mock Get-ChildItem -ModuleName EnablePython -MockWith {
        return @(
            [PSCustomObject]@{
                PSChildName = "3.3"
                PSPath = "HKCU:\SOFTWARE\Python\MyPythonCore\3.3"
            } )
    } -ParameterFilter {
        $Path -and $Path -eq "HKCU:\SOFTWARE\Python\MyPythonCore"
    }

    Mock Get-ChildItem -ModuleName EnablePython -MockWith {}

    # Get-Item
    #
    Mock Get-Item -ModuleName EnablePython -MockWith {
        return [PSCustomObject]@{
            PSPath = "HKLM:\SOFTWARE\Python\MyPythonCore\3.6\InstallPath"
        }
    } -ParameterFilter {
        $Path -and $Path -eq "HKLM:\SOFTWARE\Python\MyPythonCore\3.6\InstallPath"
    }

    Mock Get-Item -ModuleName EnablePython -MockWith {
        return [PSCustomObject]@{
            PSPath = "HKLM:\SOFTWARE\Python\MyPythonCore\2.7\InstallPath"
        }
    } -ParameterFilter {
        $Path -and $Path -eq "HKLM:\SOFTWARE\Python\MyPythonCore\2.7\InstallPath"
    }

    Mock Get-Item -ModuleName EnablePython -MockWith {
        return [PSCustomObject]@{
            PSPath = "HKLM:\SOFTWARE\WOW6432Node\Python\MyPythonCore\2.7\InstallPath"
        }
    } -ParameterFilter {
        $Path -and $Path -eq "HKLM:\SOFTWARE\WOW6432Node\Python\MyPythonCore\2.7\InstallPath"
    }

    Mock Get-Item -ModuleName EnablePython -MockWith {
        return [PSCustomObject]@{
            PSPath = "HKCU:\SOFTWARE\Python\MyPythonCore\3.3\InstallPath"
        }
    } -ParameterFilter {
        $Path -and $Path -eq "HKCU:\SOFTWARE\Python\MyPythonCore\3.3\InstallPath"
    }

    Mock Get-Item -ModuleName EnablePython -MockWith {}

    # Get-ItemPropertyValue
    #
    Mock Get-ItemPropertyValue -ModuleName EnablePython -MockWith {
        return "C:\MyPython3.6"
    } -ParameterFilter {
        $Path -and $Path -eq "HKLM:\SOFTWARE\Python\MyPythonCore\3.6\InstallPath"
    }

    Mock Get-ItemPropertyValue -ModuleName EnablePython -MockWith {
        return "C:\MyPython2.7"
    } -ParameterFilter {
        $Path -and $Path -eq "HKLM:\SOFTWARE\Python\MyPythonCore\2.7\InstallPath"
    }

    Mock Get-ItemPropertyValue -ModuleName EnablePython -MockWith {
        return "C:\MyPython2.7-x86"
    } -ParameterFilter {
        $Path -and $Path -eq "HKLM:\SOFTWARE\WOW6432Node\Python\MyPythonCore\2.7\InstallPath"
    }

    Mock Get-ItemPropertyValue -ModuleName EnablePython -MockWith {
        return "C:\Users\Me\AppData\MyPython3.3"
    } -ParameterFilter {
        $Path -and $Path -eq "HKCU:\SOFTWARE\Python\MyPythonCore\3.3\InstallPath"
    }

    Mock Get-ItemPropertyValue -ModuleName EnablePython -MockWith {}

    # Get-DistributionVersion
    #
    Mock Get-DistributionVersion -ModuleName EnablePython -MockWith {
        return "3.6"
    } -ParameterFilter {
        $InstallPath -and $InstallPath -eq "C:\MyPython3.6"
    }

    Mock Get-DistributionVersion -ModuleName EnablePython -MockWith {
        return "2.7"
    } -ParameterFilter {
        $InstallPath -and $InstallPath -eq "C:\MyPython2.7"
    }

    Mock Get-DistributionVersion -ModuleName EnablePython -MockWith {
        return "2.7"
    } -ParameterFilter {
        $InstallPath -and $InstallPath -eq "C:\MyPython2.7-x86"
    }

    Mock Get-DistributionVersion -ModuleName EnablePython -MockWith {
        return "3.3"
    } -ParameterFilter {
        $InstallPath -and $InstallPath -eq "C:\Users\Me\AppData\MyPython3.3"
    }

    Mock Get-DistributionVersion -ModuleName EnablePython -MockWith {}

    # Get-DistributionBitness
    #
    Mock Get-DistributionBitness -ModuleName EnablePython -MockWith {
        return "64"
    } -ParameterFilter {
        $InstallPath -and @("C:\MyPython3.6", "C:\MyPython2.7", "C:\Users\Me\AppData\MyPython3.3").Contains( $InstallPath )
    }

    Mock Get-DistributionBitness -ModuleName EnablePython -MockWith {
        return "32"
    } -ParameterFilter {
        $InstallPath -and $InstallPath -eq "C:\MyPython2.7-x86"
    }

    Mock Get-DistributionBitness -ModuleName EnablePython -MockWith {}
}
