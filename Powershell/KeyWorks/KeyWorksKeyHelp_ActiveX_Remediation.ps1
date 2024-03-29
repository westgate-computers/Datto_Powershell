######################## Script_Template ############################
# Description: This script uses a registry file named               #
# "KeyWorks_ActiveX_Registry.reg" to set kill bits for KeyWorks     #
# ActiveX controls. This remediates: 62311 - KeyWorks KeyHelp       #
# ActiveX Control Multiple Vulnerabilities.                         #
# Ref: http://sotiriu.de/adv/NSOADV-2010-008.txt

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 11/14/2023 - Created Script                                       #

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

# Test if .reg file exists before applying: ref: https://adamtheautomator.com/powershell-check-if-file-exists/
if (Test-Path -Path "C:\temp\KeyWorks_ActiveX_Registry.reg")
{
    # Apply remediation: ref: https://stackoverflow.com/questions/49676660/how-to-run-the-reg-file-using-powershell
    reg import "C:\temp\KeyWorks_ActiveX_Registry.reg"
    Datto_Output("MSXML Parser Remediation applied successfully!")
}
else {
    Write-Error "Couldn't find .reg file at C:\temp\KeyWorks_ActiveX_Registry.reg"   
}

exit $LastExitCode