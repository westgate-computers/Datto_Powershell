####################### view_msi_database ###########################
# Describe script here: Lists all installed msi's on PC, including  #
# Product code, upgrade code and the Name.                          #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 04/26/2023 - Created Script                                       #
# 08/08/2023 - added redirection for Write-Host variable
# 08/08/2023 - Pulled from https://stackoverflow.com/questions/46637094/how-can-i-find-the-upgrade-code-for-an-installed-msi-file/46637095#46637095

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

$wmipackages = Get-WmiObject -Class win32_product
$wmiproperties = gwmi -Query "SELECT ProductCode,Value FROM Win32_Property WHERE Property='UpgradeCode'"
$packageinfo = New-Object System.Data.Datatable
[void]$packageinfo.Columns.Add("Name")
[void]$packageinfo.Columns.Add("ProductCode")
[void]$packageinfo.Columns.Add("UpgradeCode")

foreach ($package in $wmipackages) 
{
    $foundupgradecode = $false # Assume no upgrade code is found

    foreach ($property in $wmiproperties) {

        if ($package.IdentifyingNumber -eq $property.ProductCode) {
           [void]$packageinfo.Rows.Add($package.Name,$package.IdentifyingNumber, $property.Value)
           $foundupgradecode = $true
           break
        }
    }
    
    if(-Not ($foundupgradecode)) { 
         # No upgrade code found, add product code to list
         [void]$packageinfo.Rows.Add($package.Name,$package.IdentifyingNumber, "") 
    }
}

$packageinfo | Sort-Object -Property Name | Format-table ProductCode, UpgradeCode, Name

# Enable the following line to export to CSV (good for annotation). Set full path in quotes
# $packageinfo | Export-Csv "[YourFullWriteablePath]\MsiInfo.csv"

# copy this line as well