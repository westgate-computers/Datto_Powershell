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
# MIIIuAYJKoZIhvcNAQcCoIIIqTCCCKUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBaopm+ROq13wHG
# gQTOblHrH2RSuKvqeGz1LRnWX0DXx6CCBfowggX2MIIE3qADAgECAhMgAAAAJTk+
# wdvAji8zAAEAAAAlMA0GCSqGSIb3DQEBCwUAMFQxFTATBgoJkiaJk/IsZAEZFgVs
# b2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UEAxMUd2Vz
# dGdhdGVjb21wLURDMDEtQ0EwHhcNMjUwMTIxMjIzNTI4WhcNMjcwMTIxMjI0NTI4
# WjAZMRcwFQYDVQQDEw5XYWxrZXIgQ2hlc2xleTCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBANRrq1GdQ8q02316VsSUZe5jcuCA1/rQ0CeICX2iEDV9P7uV
# 5ferUh1dTuDJjpQdVjjYARrV7U0H7c1lF+4DpE4S7IRLsiSJMUqNhdQMn58tu7Yt
# XleNWtRP+bkHX81vtJ1nlnxkdaIOKX7HN86FFclpo7osUt/bKZKBzKSDr6Y18vog
# YG4PIQLtymw/kNbkcHf1+iqW7/MQNevfmorLg06xpeKoEdw9B4CDlKUrXEEXB29y
# QFzrcdQiSX2jKToJOZnS40Ofov3Mi9adYd4fRAOVLLzytjj+vI4Ood2K06Dz8wVo
# zkcmQ2KOTUV+Kcobysc6pWF/FeGbYHvhYflkOpECAwEAAaOCAvowggL2MDwGCSsG
# AQQBgjcVBwQvMC0GJSsGAQQBgjcVCIWPl3mFh8xJg/mNCd2UeoepixJIhp2sbIS1
# w3sCAWQCAQIwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeAMBsG
# CSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFEiRW0A/zWc2uM0h
# PXDdgXnzVMfMMB8GA1UdIwQYMBaAFLWGbuIuy8p6oshJR2XtcmsxnG+HMIHdBgNV
# HR8EgdUwgdIwgc+ggcyggcmGgcZsZGFwOi8vL0NOPXdlc3RnYXRlY29tcC1EQzAx
# LUNBKDEpLENOPVdHQy1EQzAxLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2
# aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPXdlc3RnYXRlY29t
# cCxEQz1sb2NhbD9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0
# Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwgc0GCCsGAQUFBwEBBIHAMIG9MIG6
# BggrBgEFBQcwAoaBrWxkYXA6Ly8vQ049d2VzdGdhdGVjb21wLURDMDEtQ0EsQ049
# QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNv
# bmZpZ3VyYXRpb24sREM9d2VzdGdhdGVjb21wLERDPWxvY2FsP2NBQ2VydGlmaWNh
# dGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0aG9yaXR5MDYGA1Ud
# EQQvMC2gKwYKKwYBBAGCNxQCA6AdDBt3Y2hlc2xleUB3ZXN0Z2F0ZWNvbXAubG9j
# YWwwTAYJKwYBBAGCNxkCBD8wPaA7BgorBgEEAYI3GQIBoC0EK1MtMS01LTIxLTg5
# MzYxOTIyNS05ODMxNjM4NDUtNzM0MzcyNDA1LTI2MzMwDQYJKoZIhvcNAQELBQAD
# ggEBADDCZHaD3JqnGAM2Ayp0fjCkZjUJeHLfdLn3DBIVdr9XaxOqfP641az2+fVm
# tDnIDuacTIs70DoGzg33Lmel2liBsif+7NTXRHqk3mFguPeUvDbRuGQjRTnsu5DR
# nv9GdgYdoY+Dwh0eyAb4Rri+AzikMM6hytjy22xtqbfj38E/LjtXBxWtKFV1NO1Y
# xnCUvCCOuERjAnbnI2pe4Yqa8qmG6c5ii6h71V2rP5BXcqVg8EXxMHpYrypPR2F5
# mdk323TPlq58Aqf7df5dMqK5HdSlwphSAZUGzhKEVA5d5pQYujvHjwashLHRXcbo
# U/TmFTV5EvmCXaz8TZKWLJO7XlUxggIUMIICEAIBATBrMFQxFTATBgoJkiaJk/Is
# ZAEZFgVsb2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UE
# AxMUd2VzdGdhdGVjb21wLURDMDEtQ0ECEyAAAAAlOT7B28COLzMAAQAAACUwDQYJ
# YIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG
# 9w0BCQQxIgQgt+xhQ8w1ex2UoP0IdwrRgt+X1WI/fiPsOaoch8XtrxEwDQYJKoZI
# hvcNAQEBBQAEggEAcGTGx5KMI8KeZRdqCV92Av4/CFEsHlgcj6BM5Xg3Iwne7Y61
# HXM59nK3Q+DDnBocnv2mgzC/MAKlqZLbqybZXQcR3ytY3k8aezqpt53Nlcxs2L0b
# IZp+QjsNt514RjNgjDfLh2mGNG9kVYjtfmdhy2wK096Tp5rB0lkPqMbY16KB04/6
# mEJjC3JqUm6BTdGsLgxVOKnIsiRqKUFadEMuecdcA2SBNRsbAPaMsxtTDOykpSfp
# kpFAcOZ35uUFGHjyOYqYpOlI69gl8GbeQCJlfcmatwioii4tHr7zZrFN7HKsoTLi
# TlxkYzwYRLYv9ZFVzexvo7fgD0ytJyXXu5WTYA==
# SIG # End signature block
