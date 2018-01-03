@echo off
findstr /c:"Completed REDO" %1  > nul
if %errorlevel%==0 (
echo ----------------
echo %2 Load Success! 
echo ----------------
GOTO :EOF
) else (
GOTO MSG_3101
)

:MSG_3101
findstr /C:"Msg 3101" %1 > nul
if %errorlevel%==0 (
echo ----------------
echo %2 Load Failed!
echo Msg 3101 - Database in use. A user with System Administrator (SA) role must have exclusive use of database to run load.
echo ----------------
) else (
GOTO MSG_4002
)

:MSG_4002
findstr /C:"Msg 4002" %1 > nul
if %errorlevel%==0 (
echo ----------------
echo %2 Load Failed!
echo Msg 4002 - Login failed.
echo ----------------
) else (
GOTO MSG_4305
)

:MSG_4305
findstr /C:"Msg 4305" %1 > nul
if %errorlevel%==0 (
echo ----------------
echo %2 Load Failed!
echo Msg 4305 - Specified log dump file is out of sequence. Please run a complete database dump before trying a log load again.
echo ----------------
) else (
echo ----------------
echo "$2" Load Failed!
echo Unknown Error. Check Logs for details.
echo ----------------
GOTO :EOF
)

:EOF
