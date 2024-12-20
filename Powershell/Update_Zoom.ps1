######################### Update_Zoom ###############################
# Describe script here: Installs Zoom client for meetings if it's   #
# not present. If it exists, updates to latest version available.   #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/22/2023 - Created Script                                       #
# Script pulled from: https://github.com/YSSVirus/Admin_Powershell_Scripts/blob/main/Automated%20Software%20Installs/Zoom_installer-or-Updater.ps1
# 09/01/2023 - Script debugging...removed removing_old_zoom func
# changed C:\temp_zoom to C:\temp as C:\temp_zoom was never created
# by original script. Removed ?arch=x64 from download URL. 

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

function main(){ #This is our main function for organization
	$ErrorActionPreference = "Stop"
	$Version_Powershell_Major = $PSVERSIONTABLE.PSVersion.Major
	function Error_Handling($text){
	$PSItem.ScriptStackTrace
	$PSItem.Exception.Message
	$ProgressPreference = 'SilentlyContinue'
	}
	# function Removing_Old_Zoom(){ #This will uninstall any old Zoom version avoiding side by side issues
	# 	$zip_path = "C:\temp_zoom\CleanZoom.zip"
	# 	$exe_path = "C:\temp_zoom\CleanZoom.exe"
	# 	$Zoom_Uninstaller = "https://support.zoom.us/hc/en-us/article_attachments/360084068792/CleanZoom.zip"
	# 	$Zoom_Uninstaller_Path = "C:\temp_zoom\CleanZoom.zip"
	# 	$command = "invoke-webrequest" + " -uri " + "$Zoom_Uninstaller" + " -OutFile " + "$zip_path"
	# 	Try {
	# 		Invoke-Expression -Command $command | Out-Null
	# 		while (!(Test-Path $Zoom_Uninstaller_Path)) { Start-Sleep 1 }
	# 	}#Downloading the uninstaller
	# 	catch{
	# 		$Error_Text = 'Could not download the un-installer for zoom'
	# 		Error_Handling($Error_Text)
	# 		exit
	# 	}#error if it cant download un-installer
	# 	Expand-Archive -Path "C:\temp_zoom\CleanZoom.zip" -DestinationPath "C:\temp_zoom\"
	# 	Start-Process ".\CleanZoom.exe" -ArgumentList "/silent /keep_outlook_plugin /keep_lync_plugin /keep_notes_plugin" -wait
	# }
	function Downloading_Zoom(){
		$Download_URL = "https://zoom.us/client/latest/ZoomInstallerFull.msi"
		Set-Location "C:\temp"
		$command = "invoke-webrequest" + " -uri " + "$Download_URL" + " -OutFile " + "C:\temp\ZoomInstaller.msi"
		Try { #Now we try running that with first chrome, then the default browser, then it will print the link out if nothing else works
			Invoke-Expression "$command"
			while (!(Test-Path "C:\temp\ZoomInstaller.msi")) { Start-Sleep 1 }
		}
		catch{
			$Error_Text = 'Could not download the installer for zoom'
			Error_Handling($Error_Text)
			exit
		}
		try{
			Start-Process "./ZoomInstaller.msi" -ArgumentList "/qn /passive /quiet /norestart /log install.log" -Wait
		}
		catch{
			echo 'Zoom could not install'
		}
	}
	$checking = Test-Path "C:\temp\ZoomInstaller.msi" ###change
	$Start_Dir = $PWD
	$Download_Dir = "C:\temp\"
	Set-Location $Download_Dir
	Try{
		$File_Checker = "C:\temp\ZoomInstaller.msi"
	}#testing to see if there is any old previously downloaded installers then removes them
	Catch{
		$File_Checker = 'NULL'
	}#This is mainly a placeholder in-case there is no old installer
	# if ($checking){
	# 	Removing_Old_Zoom
	# }# this uninstalls the old version of zoom IF THE USER HAS IT
	Downloading_Zoom #Here we install zoom
	cd $Start_Dir
}


# $req = Invoke-WebRequest -uri "https://www.deepfreeze.com/Cloud/pr/softwareupdater/Latest" -UseBasicParsing
# $req_content = $req.RawContent
# $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Zoom*"
# if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Zoom*") -eq "$null"){
# 	$key = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Zoom*"
# 	$installLocation = (Get-ItemProperty -Path $key -Name "DisplayVersion").DisplayVersion
# 	$zoom_version = $installLocation.Split(" ")[0]
# }
# else{
# 	$installLocation = (Get-ItemProperty -Path $key -Name "DisplayVersion").DisplayVersion
# 	$zoom_version = $installLocation.Split(" ")[0]
# }
# Datto_Output("Zoom Version: $zoom_version") 
# if (($req_content -NotContains "Zoom updated to $zoom_version") -or ($zoom_version -eq $null)){
# 	main #main
# }
main
exit #exit upon completion

# SIG # Begin signature block
# MIIItQYJKoZIhvcNAQcCoIIIpjCCCKICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBaopm+ROq13wHG
# gQTOblHrH2RSuKvqeGz1LRnWX0DXx6CCBfcwggXzMIIE26ADAgECAhMgAAAAFmQu
# 3GTajaaOAAAAAAAWMA0GCSqGSIb3DQEBCwUAMFQxFTATBgoJkiaJk/IsZAEZFgVs
# b2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UEAxMUd2Vz
# dGdhdGVjb21wLURDMDEtQ0EwHhcNMjQwOTE4MjAzMzMxWhcNMjUwMTEzMTk1NDQ2
# WjAZMRcwFQYDVQQDEw5XYWxrZXIgQ2hlc2xleTCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBALdQvSsBcZJrgzxqe048NIx6FztzFNcu8CbziEvfMjNSnzVY
# FpQ4SqZV955ub+/6QnkNrhHY+pQlPeajpcOvgCysdGBSe26+8MpC8xGjzLU5MeOT
# cPTZAs/oSo1J9vAo94zUHguV/t0f7KlBhFmnFrkCrOA3nwsh2VFWD+OZYKKyv7tP
# uAzwVFNROKCJt+wpC+OK3akgr8bMM/S/gEl4hGkV2exHv3hdZZPUbchRhwvtH2Ax
# 3YC1EAqxPGns5uM98qqYpU9fe/BLoYFESu1Sno9/p0c9cwLqXQcs9aVrUm8AZgsR
# ed+zdAcMlbLWWBshK47L/bnPx50OILB7NvlPjpUCAwEAAaOCAvcwggLzMDwGCSsG
# AQQBgjcVBwQvMC0GJSsGAQQBgjcVCIWPl3mFh8xJg/mNCd2UeoepixJIhp2sbIS1
# w3sCAWQCAQIwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeAMBsG
# CSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFHP608OuQEkxYq3u
# zEw2N/A53E3VMB8GA1UdIwQYMBaAFGDzwfRAj9EqefCsmrUwHE3f1WieMIHaBgNV
# HR8EgdIwgc8wgcyggcmggcaGgcNsZGFwOi8vL0NOPXdlc3RnYXRlY29tcC1EQzAx
# LUNBLENOPVdHQy1EQzAxLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNl
# cyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPXdlc3RnYXRlY29tcCxE
# Qz1sb2NhbD9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0Q2xh
# c3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwgc0GCCsGAQUFBwEBBIHAMIG9MIG6Bggr
# BgEFBQcwAoaBrWxkYXA6Ly8vQ049d2VzdGdhdGVjb21wLURDMDEtQ0EsQ049QUlB
# LENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZp
# Z3VyYXRpb24sREM9d2VzdGdhdGVjb21wLERDPWxvY2FsP2NBQ2VydGlmaWNhdGU/
# YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0aG9yaXR5MDYGA1UdEQQv
# MC2gKwYKKwYBBAGCNxQCA6AdDBt3Y2hlc2xleUB3ZXN0Z2F0ZWNvbXAubG9jYWww
# TAYJKwYBBAGCNxkCBD8wPaA7BgorBgEEAYI3GQIBoC0EK1MtMS01LTIxLTg5MzYx
# OTIyNS05ODMxNjM4NDUtNzM0MzcyNDA1LTI2MzMwDQYJKoZIhvcNAQELBQADggEB
# ACTp/R8QXQAHRY7b4gV/4RNUfCWBBj5CAsqZXy8pGGpFiAX6inB64CBhqbKD7djv
# elBUCtmBICHbQ5gj/gHKdeIs2Pe6TxJMUbz3D9cNCVZ/bZFLxUZ1zWr/VwNsUXEL
# zqGLwX7Cy/OJaUmQDFSJGfXLbdfyKywa3qgl8j5YOjXItOcf86d9HiN9eDJfW077
# YsYiNeWsg4IAVRpjuDvzGPu+ropqCtJuNLk7cKHQjTU4RTCUzifJON8z7uFU+Hl0
# QutmghDCjojqvWsoAOUIaF4EQ+ZnuTaFuL5bQX4M4bHk6QI/xE4o5RkBPoeNuNE7
# NE1hS/lI3CECKUoA5598UusxggIUMIICEAIBATBrMFQxFTATBgoJkiaJk/IsZAEZ
# FgVsb2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UEAxMU
# d2VzdGdhdGVjb21wLURDMDEtQ0ECEyAAAAAWZC7cZNqNpo4AAAAAABYwDQYJYIZI
# AWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0B
# CQQxIgQgt+xhQ8w1ex2UoP0IdwrRgt+X1WI/fiPsOaoch8XtrxEwDQYJKoZIhvcN
# AQEBBQAEggEAaMR3OU0XadCV+xN/A1FYZpUuIjUDsy3Lgv+45zl/EYD9zXLpVteq
# w8mc7ifFqgZX4Dd1uKpX8A2+ufboYrmVNav7ZG/xpY/dLGG+e728oUxmgEUQtcPW
# AWsRV/Schui5i+MSOpMuu6xFPYBE1BSOBjLcgQhsXjGBnS0hppaeUkUIB1i9JpZD
# 0PAo730RE98vgkoxEO/xOZ+W2GSVKeUYWVN/AwS5D2oMe//Ud6Ya30gS3Cght8SQ
# yafAlxb0wYfgzzCIPp5y+H1bo9gdPz3MMP+uenmn7w/XMQ3li4UEo0gZ5ieSV5sn
# u0jyxlv7nrcGBolTTIKf28y2e5h3vm01rQ==
# SIG # End signature block
