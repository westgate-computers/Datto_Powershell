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
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2020/08/windows6.1-kb4571719-x64_5288d4c665b6d47f6fa9ff221b4b75a81a907ff1.msu', 'kb4571719.msu')"
echo "1 out of 3 downloaded"
echo "****"
:: Stop copy here

@echo off
cd /
:: Copy me to install KB msu file: 
wusa.exe C:\ kb4571719.msu /quiet /norestart
echo " kb4571719 is installed, processing the next one"
echo "****"
:: Stop copy here

:: Copy me to download KB
echo "Downloading Patches; This will take several minutes depends on your Internet speed"
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2020/09/windows6.1-kb4577053-x64_81540c22784dcd768d027b2577884d8157199da8.msu', 'kb4577053.msu')"
echo "2 out of 3 downloaded"
echo "****"
:: Stop copy here

@echo off
cd /
:: Copy me to install KB msu file: 
wusa.exe C:\ kb4577053.msu /quiet /norestart
echo " kb4577053 is installed, processing the next one"
echo "****"
:: Stop copy here

:: Copy me to download KB
echo "Downloading Patches; This will take several minutes depends on your Internet speed"
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2023/09/windows6.1-kb5030261-x64_e530aefef8e251188b0cfb2762a8996a793792b2.msu', 'kb5030261.msu')"
echo "3 out of 3 downloaded"
echo "****"
:: Stop copy here

@echo off
cd /
:: Copy me to install KB msu file: 
wusa.exe C:\ kb5030261.msu /quiet /norestart
echo " kb5030261 is installed, processing the next one"
echo "****"
:: Stop copy here

:: Copy me to install udpates via cab file: 
@REM dism /online /add-package /packagepath: "C:\KB5025221.cab"
@REM echo "KB5025221 is installed, processing the next one"
@REM echo "****"
:: Stop copy here

echo "Finished applying updates"