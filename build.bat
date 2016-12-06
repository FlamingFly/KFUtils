:: Build script for KillingFloor mod development
:: (c) 2015 Yamori Yuki
::
:: You may freely use, modify or distribute this script

:: first save current echo setting and turn off echo
@FOR /F "tokens=3 delims=. " %%i IN ('echo') DO @set ECHO_WAS=%%i
@echo off

:: ===== Settings =====
:: Set your paths here accordingly (no quotes please)
set PROJ_NAME=FFArms
set SRC_DIR=\your-github-project-path\sources\FFArms
set GAME_DIR=\your-steam-path\SteamApps\common\KillingFloor
set BUILD_DIR=\some-path\FFArms-builds
:: set POSTBUILD=TRUE

:: ===== Script =====

:: normalize postbuild variable
if not _%POSTBUILD%_ == _TRUE_ set POSTBUILD=FALSE

:: write out settings
echo.
call :write ---------- SETTINGS ----------
call :write Project name:      %PROJ_NAME%
call :write Source directory:  %SRC_DIR%
call :write Game directory:    %GAME_DIR%
call :write Builds directory:  %BUILD_DIR%
call :write Run postbuild:     %POSTBUILD%
call :write -------- END SETTINGS --------
echo.

:: get the dir, where this script resides
set MY_DIR=%~dp0
set MY_DIR=%MY_DIR:~0,-1%

:: get the dir th script was run from
set START_DIR=%cd%

:: prepare build dir name
set TM=%TIME:~0,8%
set TM=%TM::=-%
set TM=%TM: =0%
set BUILD=%DATE%T%TM%

:: clear workspace
call :write Clearing old files from game directory
rmdir /S /Q "%GAME_DIR%\%PROJ_NAME%" >NUL
if errorlevel 1 goto :err
if exist "%GAME_DIR%\System\%PROJ_NAME%.*" (
	del /Q "%GAME_DIR%\System\%PROJ_NAME%.*" >NUL
	if errorlevel 1 goto :err
)

:: copy source to game dir
call :write Copying sources to game directory
xcopy /E /I /Y /Q "%SRC_DIR%" "%GAME_DIR%\%PROJ_NAME%" >NUL
if errorlevel 1 goto :err

:: copy build ini to game dir
call :write Copying build.ini to build-%PROJ_NAME%.ini
copy /Y "%MY_DIR%\build.ini" "%GAME_DIR%\System\build-%PROJ_NAME%.ini" >NUL
if errorlevel 1 goto :err

:: cd into game dir to run ucc
cd /d "%GAME_DIR%\System"
:: run ucc make
call :write Running UCC make
echo.
UCC.exe make ini=build-%PROJ_NAME%.ini
if errorlevel 1 (
	set STATUS=FAIL
) else (
	set STATUS=SUCCESS
)
:: remove the file that prevents you from connecting to other servers
del steam_appid.txt

:: cd back to start dir
cd /d "%START_DIR%"

:: process UCC status
echo.
if %STATUS% == SUCCESS (
	if %POSTBUILD% == TRUE (
		call :write Running postbuild ...
		call :postbuild
		call :write Postbuild complete
	)
	call :write Build successful. Copying to builds directory
	if not exist "%BUILD_DIR%" (
		mkdir "%BUILD_DIR%" >NUL
	)
	xcopy /I "%GAME_DIR%\System\%PROJ_NAME%.*" "%BUILD_DIR%\%BUILD%" >NUL
	if errorlevel 1 goto :err
	
) else (
	call :write Build FAILED! Check output.
)

:: pause to just in case the script is not run from cmd window
echo.
call :write Press any key to finish ...
pause >NUL
:: reset echo to previous state and exit
echo %ECHO_WAS%
@exit /B 0

:err
echo.
call :write [ERROR] Error encountered. Exitting.
call :write Press any key to finish ...
pause >NUL
echo %ECHO_WAS%
@exit /B 127

:write
echo [BUILD] %*
exit /B 0

:postbuild
REM echo [POSTBUILD] Copying INI files to game dir
REM xcopy /I "%SRC_DIR%\Classes\*.ini" "%GAME_DIR%\System\" >NUL
REM if errorlevel 1 goto :err
exit /B 0