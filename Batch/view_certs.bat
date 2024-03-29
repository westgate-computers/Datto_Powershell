::======================================================================================= 
:: Script: view_certs.bat
:: Author: Walker Chesley
:: Date: 08/11/20223
:: Description: Finds all certs signed by Verisign. Either pass cert authority as 2nd
:: arguement. ie view_certs.bat "" DigiCert OR change  if "%~2"=="" (set "_Issuer=VeriSign") to "_Issuer=DigiCert" 
:: See Also: https://stackoverflow.com/questions/53092715/query-certificates-for-sha1-sha2-sha256
::=======================================================================================
@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion
if "%~2"=="" (set "_Issuer=VeriSign") else set "_Issuer=%~2"
if /I "%~1"=="" (set "_user=") else set "_user=%~1"
call :findCertSN "Root"
call :findCertSN "AuthRoot"
call :findCertSN "CA"
rem call :findCertSN "My"
ENDLOCAL
goto :eof

:findCertSN
set "_NextCert="
for /F "delims=" %%G in ('
    certutil %_user% -store "%~1"^|findstr "^Serial.Number: ^Issuer:"') do (
    set "_Line=%%G"
    if "!_Line:~0,14!"=="Serial Number:" (
      set "_NextCert=!_Line:~15!"
    ) else (
      if "!_Line:~0,7!"=="Issuer:" (
        set "_Line=!_Line:~8!"
        set "_NextIssuer="
        for %%g in (!_line!) do ( 
          set "_Elin=%%g"
          set "_Part=!_Elin:%_Issuer%=!"
          if not "!_Part!"=="!_Elin!" set "_NextIssuer=Match"
        )
        if defined _NextCert if defined _NextIssuer (
            echo %_Issuer%: %_user% -store "%~1" !_NextCert!
            set "_NextCert="
        )
      )
    )
  ) 
goto :eof