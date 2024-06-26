###################### install_Cisco_Webex ##########################
# Description: Install Cisco WebEx desktop meetings bundle using    #
# local WebEx msi file                                              #
# See: https://help.webex.com/en-us/article/nw5p67g/Webex-App-|-Installation-and-automatic-upgrade#Cisco_Reference.dita_658ec170-8b7a-4007-86d7-454c13e35ef8
# See link for msi file and install instructions                    #
#                                                                   #
#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 06/13/2024: Created Script                                        #
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

Write-Host "Installing Cisco Webex"
msiexec /i ./WebExBundle.msi /qn ACCEPT_EULA=TRUE ALLUSERS=1 AUTO_START_WITH_WINDOWS=false /norestart
Write-Host "Cisco Webex installed successfully"