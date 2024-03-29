################## Get_Certificate_Sig_Method #######################
# Description: Lists all certs by thumbprint and signing algorithm  #
# outputs to console and text file at C:\Temp\certs_n_sigs.txt      #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/24/2023 - Created Script                                       #
# 09/26/2023 - Changed how we get cert info into Datto

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

Set-Location -Path "Cert:\"
$certs_n_sigs = Get-ChildItem -Recurse | select thumbprint, subject, @{n="SignatureAlgorithm";e={$_.SignatureAlgorithm.FriendlyName}}
echo $certs_n_sigs > C:\Temp\certs_n_sigs.txt
$results = Get-Content -Path "C:\Temp\certs_n_sigs.txt"
Datto_Output($results)