$Script:ModuleName = 'ZabbixPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\..\Output\$ModuleName\$ModuleName.psd1"

Describe "Public commands have comment-based or external help" {
    Import-Module $ModuleManifestPath -Force
    $functions = Get-Command -Module $ModuleName | Where-Object { $PSitem.Name -ne 'DynamicDscConfiguration' }
    $help = foreach ($function in $functions)
    {
        Get-Help -Name $function.Name
    }
    foreach ($node in $help)
    {
        Context $node.Name {
            It "Should have a Description or Synopsis" {
                ($node.Description + $node.Synopsis) | Should Not BeNullOrEmpty
            }

            It "Should have an Example" {
                $node.Examples | Should Not BeNullOrEmpty
            }

            foreach ($parameter in $node.Parameters.Parameter)
            {
                if ($parameter -notmatch 'WhatIf|Confirm')
                {
                    It "Should have a Description for Parameter [$($parameter.Name)]" {
                        $parameter.Description.Text | Should Not BeNullOrEmpty
                    }
                }
            }
        }
    }
}
