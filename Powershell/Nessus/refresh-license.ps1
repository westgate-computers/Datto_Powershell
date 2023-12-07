####################### Refresh-license #############################
# Description: Refresh Nessus license with License key set as       #
# env var                                                           #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 09/15/2023 - Created Script                                       #

#####################################################################

& "C:\Program Files\Tenable\Nessus\nessuscli.exe" fetch --register $env:LicenseCode