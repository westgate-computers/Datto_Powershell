###################### Install_Dotnetfx35 ###########################
# Description: Uses DISM to enable dotnetfx35 if it's not already   #
# enabled.                                                          #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 09/07/2023 - Created Script                                       #

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

$Output = ""

# installState 1=enabled, 2=disabled, 3=absent, 4=unknown
if ((Get-WmiObject Win32_OptionalFeature | `
    where { $_.Name -eq 'NetFx3' -and $_.InstallState -eq 1 }) -eq $null)
{
	Write-Host 'Installing NetFx3 (please wait)'

	# install .NET 3.5 without causing a reboot
	dism /online /norestart /enable-feature /featurename:"NetFx3"
    $Output = "DotNetFx3 has been enabled and installed."			
}
else
{
	$Output = 'NetFx3 already installed'
}
Datto_Output($Output)