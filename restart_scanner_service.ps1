################### restart_scanner_service #########################
# Describe script here: run this as quick job against single PC     #
# script returns raw output from restart of windows image           # 
# acquisition service.                                              #

#####################################################################
# Author: Your_Name                                                 #
# Change List: List your changes here:                              #
# 05/1/2023 - Created Script                                        #
#                                                                   #
#####################################################################

# General Variables for Datto: 
$StartResult = Write-Host "<-Start Result->"
$EndResult = Write-Host "<-End Result->"

# Wrapper function to output data into Datto
# @param $message = The text you want to output into Datto
function Datto_Output {
    param (
        $message
    )
    $StartResult
    Write-Host "$message"
    $EndResult
}

$message = Restart-Service -Name stisvc
Datto_Output($message)