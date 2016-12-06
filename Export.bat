@echo off
if not _%2_==__ (
	echo check usage
	goto end
) else (
	ucc.exe batchexport %1 class uc ..\%1\Classes
	del steam_appid.txt 2>NUL
)
:end
pause
@echo on