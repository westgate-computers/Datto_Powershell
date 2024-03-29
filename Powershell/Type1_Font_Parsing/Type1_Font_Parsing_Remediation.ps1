######################## Script_Template ############################
# Describe script here: List how to use the script, list input      #
# arguements, return values and exit codes                          #

#####################################################################
# Author: Your_Name                                                 #
# Change List: List your changes here:                              #
# 04/26/2023 - Created Script                                       #
# 08/08/2023 - added redirection for Write-Host variable            #
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
     
    Write-Host "<-Start Result->"
    Write-Host "$message"
    Write-Host "<-End Result->"
}

# Env Variable changes: 
$ErrorView = 'NormalView'
$ErrorActionPreference = 'Stop'

<#
Variables for the script as a whole. 
$originalLocation, set to initial location on script run. This is here for future extensibility at this point.. 
originally I was going to run the section to rename ATMFD.dll first and would need to get back to our original
location to import the reg file that's bundled with Datto. 

$svc_name holds the service name we need to disable for remediation

$output placeholder for output into Datto. 
#>
$originalLocation = Get-Location
$svc_name = "WebClient"
$output = ""

# Stop and Disable WebClient Service: 
Get-Service $svc_name | Stop-Service -PassThru | Set-Service -StartupType Disabled

# Disable use of ATMFD.dll in registry: 
try {
    reg import "ATMFD-disable.reg"
}
catch {
    Write-Error "Failed to import ATMFD-disable.reg to registry"
}

# Rename ATMFD.dll: 
if ([Environment]::Is64BitOperatingSystem) 
{
    Set-Location "%windir%\syswow64"
	takeown.exe /f atmfd.dll
	icacls.exe atmfd.dll /save atmfd.dll.acl
	icacls.exe atmfd.dll /grant Administrators:F 
	rename atmfd.dll x-atmfd.dll
}
Set-Location "%windir%\system32"
takeown.exe /f atmfd.dll
icacls.exe atmfd.dll /save atmfd.dll.acl
icacls.exe atmfd.dll /grant Administrators:(F) 
rename atmfd.dll x-atmfd.dll