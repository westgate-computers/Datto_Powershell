####################### remove_Silverlight ##########################
# Describe script here: This script removes microsoft silverlight 	#
# if it is installed on the system. NuGet will also get installed	#
# as Uninstall-Package requires it to function. 					#

#####################################################################
# Author: Walker Chesley											#
# Change List: List your changes here:                              #
# 08/10/2023 - Created Script                                       #
# 08/21/2023 - Reworked script logic, was not properly uninstalling Silverlight. 
# 09/07/2023 - Add fall back with Get-WmiObject

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

$SoftwareName = "Silverlight"
 
$ItemProperties = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object DisplayName,UninstallString
 
foreach ($Item in $ItemProperties)
    {
        $DisplayName = $Item.DisplayName
        $UninstallString = $Item.UninstallString
        if($DisplayName -like "*$SoftwareName*")
            {
                Datto_Output("$DisplayName : $UninstallString")
                # Output: Microsoft Silverlight : MsiExec.exe /X{89F4137D-6C26-4A84-BDB8-2E5A4BB71E00}
                 
                # Always test this on a reference machine, first
                # Sometimes the uninstall string is wrong, right from the vendor
                # If you do run across an invalid uninstall string, fix it
                # and hard code the uninstall string into your script
                # Silverlight was missing the /qn
                cmd.exe /c "$UninstallString /qn"
            }
    }

# While the above works in some cases, it hasn't been working in all cases.
# The below section will return null if silverlight is already uninstalled. 
# This is here to serve as a fall back should the above not work. 
$AppName = "Microsoft Silverlight"
Get-WmiObject Win32_product | Where {$_.name -eq $AppName} | ForEach {

    $_.Uninstall()

}