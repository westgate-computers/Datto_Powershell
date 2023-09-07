#################### Uninstall_Application ##########################
# Description: Set desired app to var AppName and Get-WmiObject     #
# will work to remove that application from the system.             #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 09/06/2023 - Created Script                                       #

#####################################################################

$AppName = "AppName"
$AppName = Get-WmiObject Win32_Product | Select Name | findstr /I $AppName
Get-WmiObject Win32_product | Where {$_.name -eq $AppName} | ForEach {

    $_.Uninstall()

}