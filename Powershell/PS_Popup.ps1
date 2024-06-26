########################### PS_Popup ################################
# Description: Creates pop-up message to warn end users about any
# event that might be upcoming. USE WITH CAUTION! and be nice, you 
# don't want to annoy our end-users. 

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 11/14/2023 - Created Script                                       #
# 11/14/2023 - Change message to env varaible, to be set by Dato    #
# 11/15/2023 - Add $THIS to force popup to foreground window. Ref: 
# https://www.reddit.com/r/PowerShell/comments/9hrv55/how_to_topmost_true_a_systemwindowsformsmessagebox/
# 01/19/2024 - Updated Verbage, change warning to asterisk 

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

# Add .NET framework to display the message: 
Add-Type -AssemblyName System.Windows.Forms

# For running outside of Datto, ensure $env:message has a value: 
if ([string]::IsNullOrEmpty($env:message)) {
    $env:message = "ATTENTION!!! `r`nWestgate Computers is performing scheduled maintenance on your computer tonight. Please save and close all applications but leave your computer TURNED ON.";
}
else {
    $env:message = "ATTENTION!!! `r`n" + $env:message;
}

[System.Windows.Forms.MessageBox]::Show($THIS, "$env:message", "Westgate Alert", "OK", "Asterisk")