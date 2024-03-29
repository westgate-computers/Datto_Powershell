##################### Intel_AMT_Remediation #########################
# Description: Installs the attached 'intel-sa-0075 detection and   #
# mitigation.msi' and then uses this tool to detect and remediate   #
# Intel Management Engine vulnerabilities from Nessus.              #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/28/2023 - Created Script                                       #

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

# Install Detection and Mitigation tool: 
Start-Process /wait msiexec.exe /i "Intel-SA-00075 Detection and Mitigation Tool.msi" /passive /qn


# Use the tool to detect vulnerability: 
"C:\Program Files (x86)\Intel\Intel-SA-00075 Detection and Mitigation Tool\Intel-SA-00075-console.exe" | Invoke-Expression

# Now use the tool to remediat the vulnerability: 
"C:\Program Files (x86)\Intel\Intel-SA-00075 Detection and Mitigation Tool\Intel-SA-00075-console.exe -u" | Invoke-Expression

# Now remove the Intel-SA-00075 installation
Start-Process /wait msiexec.exe /x "Intel-SA-00075 Detection and Mitigation Tool.msi" /qn /passive

# On my system, directories werent' removed after uninstallation
rm -Recurse -Force -Path "C:\Program Files (x86)\Intel\Intel-SA-00075 Detection and Mitigation Tool"