############## Insecure_Service_Permissions_Check ###################
# Description: Use accesschk.exe to search for insecure windows     #
# service permissions. This script does nothing but list insecure   # 
# services.                                                         #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/25/2023 - Created Script                                       #
# 09/05/2023 - bundle AccessChk.exe with this in Datto              #
# 09/22/2023 - add checks for Domain Users and Users

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


$AuthUsrs = ./accesschk.exe -accepteula -uwcqv “Authenticated Users” *
$Everyone = ./accesschk.exe -accepteula -uwcqv “Everyone” *
$DomainUsers = ./accesschk.exe -accepteula -uwcqv "Domain Users" *
$Users = ./accesschk.exe -accepteula -uwcqv "Users"

Datto_Output("Insecure services for Authorized Users:`n$AuthUsrs`n`nInsecure services for Everyone:`n$Everyone`nDomain Users:`n$DomainUsers`nUsers:`n$Users")