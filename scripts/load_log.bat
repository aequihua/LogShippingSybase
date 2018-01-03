@echo off

set USER=sapsa
REM Destination DB User Name e.g. sa
set PASS=Dim3xS4P
REM Destination DB User Password e.g. password
set ASESERVER=PRO
REM Destination ASE Server Name (not the hostname) e.g. SYBASE
set SQL_SCRPT_LOC=c:\logshipping\sql
REM Location of the SQL Scripts on Destination e.g. c:\logship\sql
set LOG_LOC=c:\logshipping\log
REM Location of the Log Files on Destination e.g. c:\logship\log

isql -U%USER% -P%PASS% -S%ASESERVER% -X -i %SQL_SCRPT_LOC%\load_log.sql -o %LOG_LOC%\logload.log

echo --------------------------------------------------------
echo Log Load Completed! Checking if it finished successfully!
echo --------------------------------------------------------