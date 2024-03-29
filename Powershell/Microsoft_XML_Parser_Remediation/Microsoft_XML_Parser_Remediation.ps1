################### MSXML_Parser_Remediation ########################
# Description: Uses a .reg file to apply remediation. This disables #
# MSXML v3.0.x on the local system.                                 #
# Ref: https://learn.microsoft.com/en-us/security-updates/SecurityBulletins/2014/ms14-067?redirectedfrom=MSDN

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
# Stop on errors: 
$ErrorActionPreference = "Stop"

# Test if .reg file exists before applying: ref: https://adamtheautomator.com/powershell-check-if-file-exists/
if (Test-Path -Path "C:\temp\MSXML_Parser_Remediation.reg")
{
    # Apply remediation: ref: https://stackoverflow.com/questions/49676660/how-to-run-the-reg-file-using-powershell
    reg import "C:\Temp\MSXML_Parser_Remediation.reg"
    Datto_Output("MSXML Parser Remediation applied successfully!")
}
else {
    Write-Error "Couldn't find .reg file at C:\Temp\MSXML_Parser_Remediation.reg";   
}

try {
    # Remove msxml4.dll to make Nessus happy: 
    Write-Host "Removing msxml4.dll to make Nessus happy";
    Move-Item -Force "C:\Windows\sysWOW64\msxml4.dll" "C:\Temp\msxml4.dll.old";
    Write-Host "msxml4.dll moved outside of C:\Windows\sysWOW64\ and into C:\Temp. Beginning change to ACL of this file";
    $acl = get-acl -Path "C:\Users\Public\Documents";
    Write-Host "Got ACL of C:\Users\Public\Documents as $acl";
    Set-Acl -AclObject $acl "C:\Temp\msxml4.dll.old";
    Write-Host "Set acl against msxml4.dll";
    Remove-Item -Force "C:\Temp\msxml4.dll.old";
    Write-Host "Removed file msxml4.dll";
}
catch {
    Write-Error "Error removing msxml4.dll from C:\Windows\sysWOW64\"
}

exit $LastExitCode
