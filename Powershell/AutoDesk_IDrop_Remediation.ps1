################## AutoDesk_IDrop_Remediation #######################
# Description: Removes IDrop.ocx files from default directory       #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 09/07/2023 - Created Script                                       #

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
$JobResults = ""
if(Test-Path "C:\Autodesk\WI\Autodesk AutoCAD Civil 3D 2018\x64\ACAShared\Windows\Downloaded Program Files\")
{
    Remove-Item -Recurse -Force "C:\Autodesk\WI\Autodesk AutoCAD Civil 3D 2018\x64\ACAShared\Windows\Downloaded Program Files\IDrop*"
    $JobResults = "x64 Idrop.ocx files have been removed`n"
}
if(Test-Path "C:\Autodesk\WI\Autodesk AutoCAD Civil 3D 2018\x64\ACAShared\Windows\Downloaded Program Files\")
{
    Remove-Item -Recurse -Force "C:\Autodesk\WI\Autodesk AutoCAD Civil 3D 2018\x64\ACAShared\Windows\Downloaded Program Files\IDrop*"
    $JobResults += "x86 IDrop.ocx files have been removed`n"

}
if(Test-Path "C:\Windows\Downloaded Program Files")
{
    Remove-Item -Recurse -Force "C:\Windows\Downloaded Program Files\IDrop*"
    $JobResults += "IDrop files removed from C:\Windows dir"
}

Datto_Output($JobResults)