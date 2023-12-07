###################### Nessus - Update Plugins ######################
# Update script for Nessus, to be used with Datto RMM.              #
# Script downloads the latest plugins using a unique URL from       #
# tenable designed for offline Nessus installs                      #
# ref: https://docs.tenable.com/nessus/Content/ManageNessusOffline.htm

#####################################################################
# Author: Brandon Terry & Walker Chesley                            #
# Change List: List your changes here:                              #
# 05/23/2022 - Created Script                                       #
# 10/17/2023 - Add error variables & updated plugin URL ~wchesley	#

#####################################################################

# Env Variable changes: 
$ErrorView = 'NormalView'
$ErrorActionPreference = 'Stop'

# Force use of TLS: 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

$url = $Env:NessusOfflineUrl
$temp = "C:\temp"
$file = "all-2.0.tar.gz"
$software = "Tenable Nessus (x64)"
$path = "C:\Program Files\Tenable\Nessus\nessuscli.exe"
$arguments = "update $temp\$file"

# Check if Nessus is installed: 
$installed = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -contains $software }) -ne $null

If ($installed) {
  Write-output "Checking for temp folder and creating if necessary."
  New-Item -ItemType Directory -Force -Path $temp

  Write-output "Downloading plugins..."
	Invoke-WebRequest -Uri $url -OutFile $temp\$file
  Write-output "Plugins downloaded to $temp..."

  Write-output "Updating plugins..."
	Start-Process -Wait -FilePath $path -ArgumentList $arguments
	Write-output "Plugins have been successfully updated."
	Exit 0;
}
else {
	Write-Error "Nessus is not installed. Plugins could not be updated."
	Exit 1;
} 
