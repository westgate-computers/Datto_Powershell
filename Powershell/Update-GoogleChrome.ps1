###################### Update_GoogleChrome###########################
# Description: Updates Google Chrome to latest version              #
# This script assumes Chrome is installed to the default location
# C:\Program Files (x86)\Google\Update\GoogleUpdate.exe
# This script does not confirm current chrome version or update
# status. All it does now is kickoff the update schedueler for
# Chrome manually
#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/15/2023 - Created Script                                       #
# TODO: Implement GPO to update Chrome: https://support.google.com/chrome/a/answer/6350036?sjid=5050785786002697780-NA#zippy=%2Cget-the-google-update-policy-template%2Cset-chrome-browser-to-a-specific-release-channel%2Cschedule-auto-updates-outside-of-work-hours
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

$updateChrome = Invoke-Command -ScriptBlock {"C:\Program Files (x86)\Google\Update\GoogleUpdate.exe /ua /installsource scheduler"}
Datto_Output($updateChrome)