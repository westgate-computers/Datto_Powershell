rem ################## Nessus - Install and Configure ###################
rem # Install script for Nessus, to be used with Datto RMM.             #
rem # Script installs Nessus and restores config from backup.           #
rem #####################################################################
rem # Author: Brandon Terry                                             #
rem # Change List: List your changes here:                              #
rem # 05/25/2022 - Replaced batch script with Powershell script         #
rem # 6/13/2023 - Replaced Powershell script with batch script          #
rem # 6/28/2023 - Commented out the admin pwd change until it works     #
rem # 08/09/2023 - Updated Nessus installer to 10.5.4 ~wchesley         #
rem #####################################################################
@echo off

set nessusUsername=svcNessus
set targetFolder=C:\temp
set sourceFile=Nessus_Backup.tar.gz

echo Checking to see if Nessus is already installed...
reg query "HKLM\SOFTWARE\Tenable\Nessus" > nul 2>&1
if %errorlevel% equ 0 (
    echo Tenable Nessus is already installed.
    exit /b
) 
else (
echo Installing software...
echo Current directory: %CD%
start /B /wait Nessus-10.5.4-x64.msi /quiet
echo Software installation complete.
)

echo Restoring configuration from backup...
echo Copying backup file to temp folder...
if not exist %targetFolder% (
    rem Create the target folder if it doesn't exist
    mkdir %targetFolder%
) 
else (
echo Copying backup file to %targetFolder%...
copy %sourceFile% %targetFolder%
echo File copied successfully to "%targetFolder%".
)

echo Stopping service...
net stop "Tenable Nessus"
echo Nessus service stopped.

echo Restoring backup configuration...
"C:\Program Files\Tenable\Nessus\nessuscli.exe" backup --restore %targetFolder%\%sourceFile%
echo Backup configuration restored.

echo Starting service...
net start "Tenable Nessus"

rem echo Updating Nessus Admin password...
rem echo %nessusAdminLogin% | pushd "C:\Program Files\Tenable\Nessus\" nessuscli.exe chpasswd admin
rem popd

rem if %USERDOMAIN%=="" (
rem     echo Computer is not joined to a domain.
rem     echo Checking for existing service account...
rem     net user %nessusUsername% >nul 2>&1
rem     if %errorlevel% equ 0 (
rem         echo Service account exists. Updating password...
rem         net user %nessusUsername% %nessusServiceLogin%
rem         echo Password updated.
rem     ) else (
rem         echo No account found. Creating Nessus service account...
rem         net user %nessusUsername% %nessusServiceLogin% /add
rem         echo Service account created.
rem         echo Adding Nessus service account to local admin group...
rem         net localgroup "Administrators" %nessusUsername% /add
rem         echo Service account added to Administrators group.
rem     )
rem ) else (
rem     echo This is when a domain account would have been created.
rem     )
rem )

echo Updating software...
pushd "C:\Program Files\Tenable\Nessus\" nessuscli.exe update
popd
echo Update complete.

@PAUSE