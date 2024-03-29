####################### OpenOfice_Update ############################
# Description: Updates OpenOffice to v4.1.14 using bundled msi
# in Datto. See https://www.openoffice.org/download/ for different
# OpenOffice versions. 

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 09/05/2023 - Created Script                                       #

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

start /wait msiexec /qn /norestart /i openoffice4114.msi

Datto_Output("Open Office update to 4.1.14 has ran")