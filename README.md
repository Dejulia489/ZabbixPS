# ZabbixPS

A PowerShell module that makes interfacing with Zabbix a bit easier.

## Building

Run the build script in the root of the project to install dependent modules and start the build

    .\build.ps1

### Default Build

Run the following within the root of the project.

```Powershell
Invoke-Build
```

### Cleaning the Output

```Powershell
Invoke-Build Clean
```

## Installing the Module

Install the module

```Powershell
Install-Module 'ZabbixPS' -Repository 'PSGallery'
```

##### Authors

Michael Dejulia

#### Based on:

- [psbbix](https://github.com/yubu/psbbix-zabbix-api) by yubu
- [Zabbix](https://onedrive.live.com/?cid=3b909e9df5dc497a&id=3B909E9DF5DC497A%213668&ithint=folder,psm1&authkey=!AJrwHxfukZT-ueA) by Benjamin RIOUAL
- [ZabbixPosh Api](https://zabbixposhapi.codeplex.com/) by simsaull

##### Zabbix Docs:

- [Zabbix API Libraries](http://zabbix.org/wiki/Docs/api/libraries)
- [Zabbix 2.4 API documentation](https://www.zabbix.com/documentation/2.4/manual/api)
- [Zabbix 3.4 API documentation](https://www.zabbix.com/documentation/3.4/manual/api)
- [Zabbix 4.2 API documentation](https://www.zabbix.com/documentation/4.2/manual/api)
