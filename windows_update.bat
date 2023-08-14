::======================================================================================= 
:: Script: update_windows.bat
:: Author: Walker Chesley
:: Date: 08/14/20223
:: Description: batch file to download and install requested updates from Microsoft Update Catalogue. 
:: See Also: https://www.thewindowsclub.com/batch-file-to-download-install-windows-updates
:: Usage: Grab list of download URL's for each KB you are needing to apply from Microsoft Update Catalogue. 
:: Copy the first powershell -Command and edit, replacing the current KB download link with yours. 
:: Copy the wusa.exe line and edit to install teh KB you've downloaded. 
::=======================================================================================

@echo off
cd /
:: Copy me to download KB
echo "Downloading Patches; This will take several minutes depends on your Internet speed"
powershell -Command "(New-Object Net.WebClient).DownloadFile('http://download.windowsupdate.com/c/msdownload/update/software/uprl/2020/03/windows-kb000000-x64-v5.81_74132082f1421c2217b1b07673b671ceddba20fb.exe', ' kb000000_Scan.exe')"
echo "1 out of 4 downloaded"
echo "****"
:: Stop copy here

@echo off
cd /
:: Copy me to install KB
wusa.exe C:\ kb000000.msu /quiet /norestart
echo " kb000000 is installed, processing the next one"
echo "****"
:: Stop copy here