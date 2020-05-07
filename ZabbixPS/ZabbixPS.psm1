[CmdletBinding()]
param()

$Script:PSModuleRoot = $PSScriptRoot
$Script:ModuleName = "ZabbixPS"
$Script:AppDataPath = [Environment]::GetFolderPath('ApplicationData')
$Script:ModuleDataRoot = (Join-Path -Path $Script:AppDataPath -ChildPath $Script:ModuleName)
$Script:ModuleDataRoot = (Join-Path -Path ([Environment]::GetFolderPath('ApplicationData')) -ChildPath $Script:ModuleName)
$Script:ZabbixModuleDataPath = (Join-Path -Path $Script:ModuleDataRoot -ChildPath "ModuleData.json")
$folders = 'Private', 'Public'
if (-not (Test-Path $Script:ModuleDataRoot)) { New-Item -ItemType Directory -Path $Script:ModuleDataRoot -Force }

foreach ($folder in $folders)
{
    $root = Join-Path -Path $PSScriptRoot -ChildPath $folder
    if (Test-Path -Path $root)
    {
        Write-Verbose -Message "Importing files from [$folder]..."
        $files = Get-ChildItem -Path $root -Filter '*.ps1' -Recurse |
        Where-Object Name -notlike '*.Tests.ps1'

        foreach ($file in $files)
        {
            Write-Verbose -Message "Dot sourcing [$($file.BaseName)]..."
            . $file.FullName
        }
    }
}
