@echo on

set ASESERVER=PRO
REM Name of SAP ASE Server (not the host)
set DATABASE=PRO
REM Name of SAP Database
set USER=sapsa
REM DB User
set PASS=Dim3xS4P
REM DB User Password
set SERVER=cotsrv-sapbd
REM Source DB Server Host Name
set SRC_PORT=4901
REM DB Server Port on Source
set REM_SERVER=drpsrv-sapbd
REM Destination DB Server Host Name
set REM_USER=proadm
REM Destination Server OS User
set REM_PASS=Dim3xS4P
REM Destination Server OS User Password (only needed if private key authentication not setup)
set DMP_LOC=j:\backups
REM Location of the Database Dump on Source
set TRANS_LOC=j:\backups
REM Location of the Log Dump on Source
set REM_DMP_LOC=j:\backups
REM Location of the Database Dump on Destination
set REM_TRANS_LOC=j:\backups
REM Location of the Log Dump on Destination
set DUMP_ARCH=j:\procesados
REM Location of the Dump Archives on Source and Destination
set SCRPT_LOC=C:\logshipping\scripts
REM Location of the Batch Scripts
set SQL_SCRPT_LOC=C:\logshipping\sql
REM Location of the SQL Scripts
set LOG_LOC=C:\logshipping\log
REM Location of the Logs
set LOG_ARCH=C:\logshipping\log\archive
REM Location of the Log Archives on Source and Destination

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%%MM%%DD%" & set "timestamp=%HH%%Min%%Sec%"
set "fullstamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"
set "logfname=%fullstamp%_transaction.dmp"

REM Timestamp for log file generation


::##################################################
::# -----Checking for correct parameters-----------#
::##################################################

IF !%1==! (
echo -------------------------------------------
echo Please provide correct parameters!
echo.
echo Usage: run.bat [Parameter]
echo Parameters:
echo db = Dump Database
echo log = Dump Transaction Log
echo -------------------------------------------
GOTO :EOF 
) else (

GOTO START

)

:START
if %1 == db (
echo -------------------------------------------
echo Full Database Dump will be performed
echo -------------------------------------------
GOTO DBDUMP 
) else (
GOTO START_LOG )

:START_LOG
if %1 == log (
echo --------------------------------
echo Only Log Dump will be performed
echo --------------------------------
GOTO LOGDUMP
) else (
echo -------------------------------------------
echo Please provide correct parameters!
echo.
echo Usage: run.bat [Parameter]
echo Parameters:
echo db = Dump Database
echo log = Dump Transaction Log
echo -------------------------------------------
GOTO :EOF  )


:DBDUMP

::##################################################
::# ----------- Database Dump ---------------------#
::##################################################


isql -U%USER% -P%PASS% -S%ASESERVER% -X < %SQL_SCRPT_LOC%\dump_db.sql -o %LOG_LOC%\dmpdbout.log

call %SCRPT_LOC%\chkdump.bat %LOG_LOC%\dmpdbout.log Database

goto :TRANSFERTYPE

:LOGDUMP

::##########################################################
::# -----------Incremental Dump (Log Only)-----------------#
::##########################################################

echo use %DATABASE% > %SQL_SCRPT_LOC%\dump_log.sql
echo go >> %SQL_SCRPT_LOC%\dump_log.sql
echo dump transaction %DATABASE% to "%TRANS_LOC%\%logfname%" with compression=4 >> %SQL_SCRPT_LOC%\dump_log.sql
echo go >> %SQL_SCRPT_LOC%\dump_log.sql

isql -U%USER% -P%PASS% -S%ASESERVER% -X < %SQL_SCRPT_LOC%\dump_log.sql -o %LOG_LOC%\dmplgout.log

call %SCRPT_LOC%\chkdump.bat %LOG_LOC%\dmplgout.log Log

:TRANSFERTYPE

::##########################################################
::# -----------File Transfer Section ----------------------#
::##########################################################

if %1 == db (

GOTO TRANSFER_DB 
) else (
GOTO TRANSFER_LOG )

:TRANSFER_DB

::# -----------DB Dump Transfer--------------------------#

pscp -l %REM_USER% -pw %REM_PASS% -batch -q %DMP_LOC%\database.dmp %REM_USER%@%REM_SERVER%:%REM_DMP_LOC%database.dmp > %LOG_LOC%\dbtrsfr.log 2>&1 

findstr /c:"Access denied" %LOG_LOC%\dbtrsfr.log > nul
if %errorlevel%==1 (
echo ---------------------------------
echo Database Dump Transfer Completed!
echo ---------------------------------
GOTO LOADTYPE
) else (
echo ---------------------------------
echo Database Dump Transfer Failed!
echo ---------------------------------
GOTO :EOF
)

:TRANSFER_LOG

::# -----------Log Dump Transfer--------------------------#

pscp -l %REM_USER% -pw %REM_PASS% -batch -q %TRANS_LOC%\%logfname% %REM_SERVER%:%REM_TRANS_LOC%\transaction.dmp > %LOG_LOC%\logtrsfr.log 2>&1 

findstr /c:"Access denied" %LOG_LOC%\logtrsfr.log > nul
if %errorlevel%==1 (
echo ----------------------------
echo Log Dump Transfer Completed!
echo ----------------------------
GOTO LOADTYPE
) else (
echo ----------------------------
echo Log Dump Transfer Failed!
echo ----------------------------
GOTO :EOF
)

:LOADTYPE


::##########################################################
::# -----------Loading Dump Section -----------------------#
::##########################################################

if %1 == db (

GOTO LOAD_DB 
) else (
GOTO LOAD_LOG )


:LOAD_DB

::# -----------DB Dump Load -------------------------------#

plink -l %REM_USER% -pw %REM_PASS% %REM_SERVER% %SCRPT_LOC%\load_db.bat

plink -l %REM_USER% -pw %REM_PASS% %REM_SERVER% %SCRPT_LOC%\chkload.bat %LOG_LOC%\dbload.log Database

GOTO :EOF

:LOAD_LOG

::# -----------Log Dump Load -------------------------------#

plink -l %REM_USER% -pw %REM_PASS% %REM_SERVER% %SCRPT_LOC%\load_log.bat

plink -l %REM_USER% -pw %REM_PASS% %REM_SERVER% %SCRPT_LOC%\chkload.bat %LOG_LOC%\logload.log Log

GOTO :EOF

:EOF
