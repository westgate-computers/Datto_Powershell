::======================================================================================= 
:: Script: update_windows.bat
:: Author: Walker Chesley
:: Date: 08/14/20223
:: Description: batch file to download and install requested updates from Microsoft Update Catalogue. 
:: See Also: https://www.thewindowsclub.com/batch-file-to-download-install-windows-updates
:: Usage: Grab list of download URL's for each KB you are needing to apply from Microsoft Update Catalogue. 
:: Copy the first powershell -Command and edit, replacing the current KB download link with yours. 
:: Copy the wusa.exe line and edit to install the KB you've downloaded. 
::=======================================================================================

@echo off
cd /
:: Copy me to download KB
echo "Downloading Patches; This will take several minutes depends on your Internet speed"
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2023/04/windows10.0-kb5025221-x64_51f5072d3f563a8d58dbaeee2251946b12cc4c0c.cab', 'KB5025221.cab')"
echo "1 out of 4 downloaded"
echo "****"
:: Stop copy here

@echo off
cd /
:: Copy me to install KB msu file: 
::wusa.exe C:\ kb000000.msu /quiet /norestart
::echo " kb000000 is installed, processing the next one"
::echo "****"
:: Stop copy here

:: Copy me to install udpates via cab file: 
dism /online /add-package /packagepath: "C:\KB5025221.cab"
echo "KB5025221 is installed, processing the next one"
echo "****"
:: Stop copy here

echo "Finished applying updates"