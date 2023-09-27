###################### Get_Nessus_Version ############################
# Description: Reads contents of nessus.version file and outputs     #
# version into UDF 19 and console. 

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 09/26/2023 - Created Script                                       #

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

$udf = "UDF 19"
$version = Get-Content -Path "C:\ProgramData\Tenable\Nessus\nessus.version"

#write a UDF
if ($udf -gt 0) {
    Set-ItemProperty "HKLM:\Software\CentraStage" -Name "Custom$udf" -Value "Nessus Version :: $version"
    write-host "- Writing a summary to UDF #$env:usrUDF."
} else {
    write-host "- Not writing a UDF (no field selected)."
}
Datto_Output("Nessus Version: $version")