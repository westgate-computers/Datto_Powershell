######################### Enable_IE11 ###############################
# Description: Reverse the effects of 'remove_internet_explorer11.ps1
# Assumes the removal script has been run prior to this.

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 12/06/2023 - Created Script, copied from remove_internet_explorer11.ps1

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
dism /online /Add-Capability /CapabilityName:Browser.InternetExplorer~~~~0.0.11.0 /NoRestart
$content = "============================================`n"
$content += " : DISM Log for today:`n"
$content += get-content "C:\WINDOWS\Logs\DISM\dism.log" | ? {$_ -match $(get-date -Format "yyyy-MM-dd")}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" -Name "NotifyDisableIEOptions" -Value 0 -Force
$content += "`nNotifyDisableIEOptions has been set to 0"
Datto_Output($content)