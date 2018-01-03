@echo off

findstr /c:"DUMP is complete" %1 >  nul
if %errorlevel%==0 (
echo ------------------------
echo %2 Dump Completed!
echo ------------------------
GOTO :EOF
) else (
echo ------------------------
echo %2 Dump Failed!
echo ------------------------
GOTO MSG_4002
)

:MSG_4002
findstr /c:"Msg 4002" %1 > nul
if %errorlevel%==0 (
echo ----------------
echo %2 dump Failed!
echo.
echo Msg 4002 - Login failed.
echo ----------------

GOTO MSG_7205
)

:MSG_7205
findstr /c:"Msg 7205" %1 > nul
if %errorlevel%==0 (
echo ----------------
echo %2 dump Failed!
echo.
echo Msg 7205 - Cannot open a connection to Backup Server. Check logs for more details.
echo ----------------

GOTO :EOF
)

:EOF
