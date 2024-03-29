########################### IEActiveX ###############################
# Description: Disable or Enable IEActiveX controls via GUID.       #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 12/11/2023 - Adapted script from: 
# https://mickitblog.blogspot.com/2014/05/powershell-enable-or-disable-internet.html 
# https://github.com/MicksITBlogs/PowerShell/blob/baf3f80e40039706e1f1da7789600af56b5c3010/IEActiveX.ps1

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

# Begin IEActiveX
# Script is adapted from: https://mickitblog.blogspot.com/2014/05/powershell-enable-or-disable-internet.html 
# https://github.com/MicksITBlogs/PowerShell/blob/baf3f80e40039706e1f1da7789600af56b5c3010/IEActiveX.ps1
<#
.SYNOPSIS
   Enable/Disable IE Active X Components
.DESCRIPTION
   
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   EnableIEActiveXControl "Application Name" "GUID" "Value"
   EnableIEActiveXControl "Flash for IE" "{D27CDB6E-AE6D-11CF-96B8-444553540000}" "0x00000000"
#>

#Declare Global Memory
Set-Variable -Name Errors -Value $null -Scope Global -Force
Set-Variable -Name LogFile -Value "c:\Temp\IeActiveXLogs\IEActiveX.log" -Scope Global -Force
Set-Variable -Name RelativePath -Scope Global -Force

Function GetRelativePath { 
	$Global:RelativePath = (split-path $SCRIPT:MyInvocation.MyCommand.Path -parent)+"\" 
}

Function DisableIEActiveXControl ($AppName,$GUID,$Flag) {
	$Key = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\ActiveX Compatibility\"+$GUID
	If ((Test-Path $Key) -eq $true) {
		Write-Host $AppName"....." -NoNewline
		Set-ItemProperty -Path $Key -Name "Compatibility Flags" -Value $Flag -Force
		$Var = Get-ItemProperty -Path $Key -Name "Compatibility Flags"
		If ($Var."Compatibility Flags" -eq 1024) {
			Write-Host "Disabled" -ForegroundColor Yellow
		} else {
			Write-Host "Enabled" -ForegroundColor Red
		}
	}
}

Function EnableIEActiveXControl ($AppName,$GUID,$Flag) {
	$Key = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\ActiveX Compatibility\"+$GUID
	If ((Test-Path $Key) -eq $true) {
		Write-Host $AppName"....." -NoNewline
		Set-ItemProperty -Path $Key -Name "Compatibility Flags" -Value $Flag -Force
		$Var = Get-ItemProperty -Path $Key -Name "Compatibility Flags"
		If ($Var."Compatibility Flags" -eq 0) {
			Write-Host "Enabled" -ForegroundColor Yellow
		} else {
			Write-Host "Disabled" -ForegroundColor Red
		}
	}
}

# Example usage: 
#DisableIEActiveXControl "Flash for IE" "{D27CDB6E-AE6D-11CF-96B8-444553540000}" "0x00000400"
#EnableIEActiveXControl "Flash for IE" "{D27CDB6E-AE6D-11CF-96B8-444553540000}" "0x00000000"

# DisableIEActiveXControl "Autodesk IDrop Heap Corruption" "{21E0CB95-1198-4945-A3D2-4BF804295F78}" "0x00000400"
# Keyworks: 
# {B7ECFD41-BE62-11D2-B9A8-00104B138C8C} - C:\Program Files (x86)\Pervasive Software\PSQL\bin\keyhelp.ocx
# {45E66957-2932-432A-A156-31503DF0A681} - C:\Program Files (x86)\Pervasive Software\PSQL\bin\keyhelp.ocx
# {1E57C6C4-B069-11D3-8D43-00104B138C8C} - C:\Program Files (x86)\Pervasive Software\PSQL\bin\keyhelp.ocx

DisableIEActiveXControl "$env:ControlName" "$env:ControlUID" "0x00000400"