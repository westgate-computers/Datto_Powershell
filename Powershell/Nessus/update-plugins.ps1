######################## Update-Plugins #############################
# Description: Update nessus plugins                                #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 09/15/2023 - Created Script                                       #

#####################################################################

Write-Host "Start updating nessus plugins"
& "C:\Program Files\Tenable\Nessus\nessuscli.exe" update --plugins-only | Write-Host
Write-Host "Plugins updated."