# DSCDashboard

## Description

This is a PowerShell module and a dashboard that can be installed on your DSC Pull Server to display statistics and browse the Status Reports generated by your LCM clients.
It is a GUI that uses the reporting data from the DSC Pull Server framework and makes it easily available to use.

# Prerequisites

- Windows Server 2016 Core Semi-Annual Channel release 1803
- Windows Server 2019 Insider Preview
- SQL Server

You need to have a DSC Pull Server that is configured to use a SQL Server backend. The integrated database is not supported.
This means you need to have at least Windows 2016 SAC 1803 or Windows 2019 Insider Preview.

    - Universal Dashboard Module

The dashboard is created using the Universal Dashboard module for PowerShell. You need to have this module installed on the server hosting the dashboard.
You can use either the Community or the Payed edition, depending on your usage and license requirement.

    - IIS with websockets enabled

The dashboard can run directly from PowerShell, but it is recommended to host the site in IIS. The DSCService already has a dependancy on IIS.
Also, Websockets needs to be installed and enabled in IIS for the dashboard to work properly.

## Synopsis

A PowerShell Module to

## Description

A PowerShell Module to

## Using DscDashboard

To use this module, you will first need to download/clone the repository and import the module:

```powershell
Import-Module .\DscDashboard.psm1
```

### How to use

Explain how to use this module

```powershell
New-FunctionName -Parameter1 'C:\Packages' -Parameter2 'C:\NewPackages'
```

### Using function 2 in TemplatePowerShellModule

Description on using function 1 in TemplatePowerShellModule

```powershell
Get-Function2 -Parameter1 'SomePackageName' -Parameter2 'C:\some\path_to_folder_containing_packages'
```

## Notes

```yaml
   Name: DscDashboard
   Created by: fvanroie, NetwiZe.be
   Created Date: September 15 2018
```

