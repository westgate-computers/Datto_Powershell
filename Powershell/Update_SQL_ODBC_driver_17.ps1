################### Update_SQL_ODBC_Driver_17 #######################
# Descripiton: Uses attached msodbcsql.msi to install SQL ODBC
# driver 17 to the local machine. The msodbcsql.msi file is attached
# to this script from Datto RMM. 

#####################################################################
# Author: Waker Chesley                                             #
# Change List: List your changes here:                              #
# 09/01/2023 - Created Script                                       #
# 12/19/2023 - Updated -ArgumentList                                #

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

Start-Process "msodbcsql.msi" --ArgumentList "/L*v C:\Temp\msodbcsql.log", "/qb", "IACCEPTMSODBCSQLLICENSETERMS=YES", "ALLUSERS=1" -Wait