################## Remove_Old_Dotnet_Versions #######################
# Describe script here: List how to use the script, list input      #
# arguements, return values and exit codes                          #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 11/06/2023 - Created Script                                       #
# 12/19/2023 - add .NET 3.1.32 removal, create UninstallByName func #

#####################################################################

function Datto_Output {
    <#
        .SYNOPSIS
            Wrapper function to output data into Datto
        .EXAMPLE
            Datto_Output("The software was installed")
    #>
    
    param (
        # The text you want to output into Datto
        $message
    )
    # General Variables for Datto: 
    $StartResult = Write-Host "<-Start Result->" 6>&1
    $EndResult = Write-Host "<-End Result->" 6>&1
    
    $StartResult
    Write-Host "$message"
    $EndResult
}

function UninstallByName {
    param (
        $AppName
    )
    Write-Host "Removing $AppName";
    Get-WmiObject Win32_product | Where {$_.name -eq $AppName} | ForEach { $_.Uninstall() }
}

# Env Variable changes: 
$ErrorView = 'NormalView'
# $ErrorActionPreference = 'Stop'

Write-Host "Currently installed .NET versions:"
Get-WmiObject Win32_product | findstr /I ".net"

UninstallByName("Microsoft .NET Core Runtime - 3.1.16 (x64)");

UninstallByName("Microsoft .NET Core Host - 3.1.16 (x64)");

UninstallByName("Microsoft ASP.NET Core 3.1.16 Shared Framework (x64)");

UninstallByName("Microsoft .NET Core Host FX Resolver - 3.1.16 (x64)");

UninstallByName("Microsoft .NET Core Runtime - 3.1.32 (x64)");

UninstallByName("Microsoft .NET Core Host - 3.1.32 (x64)");

UninstallByName("Microsoft ASP.NET Core 3.1.32 Shared Framework (x64)");

UninstallByName("Microsoft .NET Core Host FX Resolver - 3.1.32 (x64)");

UninstallByName("Microsoft .NET Core Host - 3.1.21 (x64)");

UninstallByName("Microsoft ASP.NET Core 3.1.21 Shared Framework (x64)");

UninstallByName("Microsoft .NET Core Host FX Resolver - 3.1.21 (x64)");

UninstallByName("Microsoft .NET Host - 5.0.17 (x86)");

UninstallByName("Microsoft .NET Core Runtime - 5.0.17 (x64)");

UninstallByName("Microsoft .NET Core Host - 5.0.17 (x64)");

UninstallByName("Microsoft ASP.NET Core 3.1.32 Shared Framework (x64)"); 

Write-Host "Script complete, remaining .NET versions:"
Get-WmiObject Win32_product | findstr /I ".net"