###################### Get_Nessus_Version ############################
# Description: Reads contents of nessus.version file and outputs     #
# version into UDF 19 and console. 

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 09/26/2023 - Created Script                                       #
# 10/02/2023 - Fix output to UDF field                              #

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

$udf = $env:UDF_19
$version = & "C:\Program Files\Tenable\Nessus\nessuscli.exe" -v

#write a UDF
if ($udf -gt 0) {
    Set-ItemProperty "HKLM:\Software\CentraStage" -Name "Custom$udf" -Value "$version"
    write-host "- Writing a summary to UDF #$udf."
} else {
    write-host "- Not writing a UDF (no field selected)."
}
Datto_Output("Nessus Version: $version")