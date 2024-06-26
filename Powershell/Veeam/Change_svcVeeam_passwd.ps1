#################### Change_svcVeeam_passwd #########################
# Description: Change or update svcVeean user password using        # 
# $env:password variable from Datto RMM.                            #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 12/11/2023 - Created Script                                       #
# 03/29/2024 - Copied svcNessus to svcVeeam                         #
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

# Env Variable changes: 
$ErrorView = 'NormalView'
$ErrorActionPreference = 'Stop'

$passwd = ConvertTo-SecureString $env:password -AsPlainText -Force
try {
    net user "svcVeeam" $passwd
    Write-Host("svcVeeam password has been updated")
}
catch {
    Write-Error("Error updating svcVeeam password")
}