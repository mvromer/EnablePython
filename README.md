# PythonSelect [![master Branch Status](https://ci.appveyor.com/api/projects/status/l8bel12152vkxbsg/branch/master?svg=true&passingText=master%20-%20OK&failingText=master%20-%20failing&pendingText=master%20-%20pending)](https://ci.appveyor.com/project/mvromer/pythonselect/branch/master)

List all available Python distributions available on a system and select the one to use within a Windows PowerShell environment. Distributions can be selected based on a number of criteria:

* Version of the bundled Python interpreter
* Maintainer of the distribution
* Whether the bundled interpreter is 32- or 64-bit
* Whether the distribution is installed for all users or just the current user

Distributions are expected to adhere to [PEP 514](https://www.python.org/dev/peps/pep-0514/), which explains rules for how Python distributions are to register themselves through the registry on Windows environments. Any distribution that adheres to this PEP (e.g., the standard Python distribution, Anaconda, etc.) can be discovered and enabled with the cmdlets provided in this module.

## Installation
PythonSelect is distributed via the PowerShell Gallery. It can be installed using the `Install-Module` cmdlet from PowerShellGet.

```
PS C:\> Install-Module PythonSelect
```

## Identifying Python Distributions
According to PEP 514, a Python distribution is identified by a pair of values: the distribution's company and the tag. As an example, the standard Python 3.6.5 distribution is identified by the company PythonCore with the tag `3.6`. As another example, the 64-bit Anaconda distribution containing Python 3.6.2 is identified by the company ContinuumAnalytics with the tag `Anaconda36-64`.

On Windows, a Python distribution can be installed either for a single user or for all users. This module refers to the former as _current user_ scope and the latter as _system_ scope. Additionally, Python distributions can either be 32- or 64-bit.

As a matter convenience, this module will inspect each Python distribution it discovers and determine the bundled interpreter's 3-part version number. This version number can be used to help identify a particular Python distribution.

The `Get-PythonDistribution` cmdlet can be used get a list of Python distributions available on the system so long as they adhere to PEP 514. With no arguments, this will return all Python distributions found on the system.

```
PS C:\> Get-PythonDistribution


Company     : ContinuumAnalytics
Tag         : Anaconda36-64
Version     : 3.6.2
Bitness     : 64
Scope       : System
InstallPath : C:\Program Files (x86)\Microsoft Visual Studio\Shared\Anaconda3_64

Company     : PythonCore
Tag         : 2.7
Version     : 2.7.14
Bitness     : 64
Scope       : System
InstallPath : C:\Python27amd64\

Company     : PythonCore
Tag         : 3.6
Version     : 3.6.5
Bitness     : 64
Scope       : System
InstallPath : C:\Python36\
```

## Filtering Python Distributions
The list of Python distributions can be filtered on any of the criteria defined above by supplying the appropriate parameters to `Get-PythonDistribution`. For example, all standard Python distributions can be returned in the following manner:

```
PS C:\> Get-PythonDistribution -Company PythonCore


Company     : PythonCore
Tag         : 2.7
Version     : 2.7.14
Bitness     : 64
Scope       : System
InstallPath : C:\Python27amd64\

Company     : PythonCore
Tag         : 3.6
Version     : 3.6.5
Bitness     : 64
Scope       : System
InstallPath : C:\Python36\
```

Distributions can also match against filter criteria that is only partially given. This is designed so that end users don't have to remember the exact filter values needed to find a specific distribution. In practice, a distribution's property will match a corresponding filter's value if any of the following conditions are met:

1. The distribution's property matches exactly the filtered value.
2. The distribution's property is prefixed by the filtered value.
3. The distribution's property is "like" the filtered value (according to the rules of the `-like` operator). This means the filtered value can contain wildcard characters.

This feature is commonly used when filtering distributions based on their version number. Rather than knowing the full version number, end users can specify a partial version number to retrieve the desired distribution. As an example, the following retrieves all Python 3.6 distributions available:

```
PS C:\> Get-PythonDistribution -Version 3.6


Company     : ContinuumAnalytics
Tag         : Anaconda36-64
Version     : 3.6.2
Bitness     : 64
Scope       : System
InstallPath : C:\Program Files (x86)\Microsoft Visual Studio\Shared\Anaconda3_64

Company     : PythonCore
Tag         : 3.6
Version     : 3.6.5
Bitness     : 64
Scope       : System
InstallPath : C:\Python36\
```

## Enabling a Python Distribution
Once a Python distribution has been identified, it can be enabled with the `Enable-Python` cmdlet. Enabling a distribution entails adding that distribution's installation and script directories to the current session's PATH. References to other Python distributions are scrubbed from the PATH.

The distribution to enable is selected by passing the same type of filtering criteria to `Enable-Python` that can be passed to `Get-PythonDistribution`. The filtering parameters that can be passed to the former cmdlet behave exactly the same as the filtering parameters that can be passed to the latter cmdlet. If the set of filtering criteria matches more than one distribution or no distributions, then an error is thrown.

For example, the following enables Python 2.7 in the current session:

```
PS C:\> Enable-Python -Version 2
Python distribution found in C:\Python27amd64\. Updating PATH.
```

### Enabling Latest Standard Python Distribution
As a special case, if no filtering parameters are passed to `Enable-Python`, then the latest standard Python distribution is enabled. In a 64-bit session, the 64-bit Python distribution is selected. Otherwise, in a 32-bit session, the 32-bit Python distribution is selected.

```
PS C:\> Enable-Python
No distribution information given. Searching for latest version of the standard Python distribution.
Python distribution found in C:\Python36\. Updating PATH.
```
