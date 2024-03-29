#################### Create_Registry_Backup ##########################
# Description: Creates backup of the registry hives HKCU, HKLM,     #
# HKCR, HKU and HKCC and places them at C:\Temp\RegBackup. Script   #
#overwrites previous backups if any. Each backup file is named      #
# after the hive with a .bak.reg extension                          #
# for example: HKCU.bak.reg                                         #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/24/2023 - Created Script                                       #

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
$regBackupDir = "C:\Temp\RegBackup"
$PathExists = (Test-Path -Path $regBackupDir)
# Ensure our location is C:\Temp
Set-Location "C:\Temp\"

# Test if path exists, if not make it: 
if (-Not $PathExists)
{
    mkdir $regBackupDir
}

# We know C:\Temp\RegBackup exists now, set our location there: 
Set-Location $regBackupDir

# Create backup of HKLM: 
reg export HKLM HKLM.bak.reg /y

# Create backup of HKCU
reg export HKCU HKCU.bak.reg /y

# Create backup of HKCR
reg export HKCR HKCR.bak.reg /y

# Create backup of HKU
reg export HKU HKU.bak.reg /y

# Create backup of HKCC
reg export HKCC HKCC.bak.reg /y

$result = (ls $regBackupDir)

Datto_Output("The following files were created to backup the registry: `n$result")