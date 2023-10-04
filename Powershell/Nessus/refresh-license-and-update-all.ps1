################ Refresh-license-and-update-all #####################
# Description: Refresh Nessus license with License key set as       #
# env var, then updates all Nessus components                       #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 10/02/2023 - Created Script                                       #
# 10/02/2023 - start and stop nessus service for version update     #

#####################################################################

Write-Host "Nessus Version before upgrade request:`n"
& "C:\Program Files\Tenable\Nessus\nessuscli.exe" -v
Write-Host "Stopping Nessus Service: "
net stop "tenable nessus"

Write-Host "Refreshing Nessus License: "
& "C:\Program Files\Tenable\Nessus\nessuscli.exe" fetch --register $env:LicenseCode
Write-Host "Update Nessus Server and Plugins: "
& "C:\Program Files\Tenable\Nessus\nessuscli.exe" update --all

Write-Host "Start Nessus Service: "
net start "tenable nessus"
Write-Host "`nNessus Version is now:`n"
& "C:\Program Files\Tenable\Nessus\nessuscli.exe" -v
Write-Host "Nessus Update Complete."