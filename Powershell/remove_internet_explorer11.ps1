################ remove_internet_explorer11.ps1 #####################
# Description: Remove IE 11 via DISM and set registry kill bit to   #
# make Nessus happy

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 04/26/2023 - Created Script                                       #
# 08/08/2023 - added redirection for Write-Host variable            #
# 11/01/2023 - set registry kill bit for IE 11                      #

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
dism /online /Remove-Capability /CapabilityName:Browser.InternetExplorer~~~~0.0.11.0 /NoRestart
$content = "============================================`n"
$content += " : DISM Log for today:`n"
$content += get-content "C:\WINDOWS\Logs\DISM\dism.log" | ? {$_ -match $(get-date -Format "yyyy-MM-dd")}
reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "NotifyDisableIEOptions" /t REG_DWORD /d 1 /f
Datto_Output($content)