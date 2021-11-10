REM This script updates AM and sets up Tomahawk folders in reaper_cache
REM !!! Precondition: !!!
REM Use 7-zip to extract the archive so the RELEASE folder is in same location as this batch file
REM  ie: Right click on the ATRT_AM_4.37.x.zip archive -> 7-Zip -> Extract Here
REM Then double-click on this batch file
@ECHO OFF

SET ETL="%~dp0\ATRT_AM\RELEASE\src\analysis\analysis.product\target\products\com.idtus.atrt.analysis.all-rest\win32\win32\x86_64\reaper_cache\etl\local"

REM Remove old ATRT RELEASE folder
RD /S /Q %~dp0\ATRT_AM\RELEASE

REM Copy new RELEASE folder to dest
robocopy %~dp0\RELEASE "C:\Users\TTWCS\Programs\ATRT_AM\RELEASE" /S /E

REM Make Tomahawk reaper_cache folders
if not exist "%ETL%\Tomahawk" MD "%ETL%\Tomahawk"
if not exist "%ETL%\Tomahawk\data" MD "%ETL%\Tomahawk\data"

REM Copy catalog folder to reaper_cache
robocopy RELEASE\5.6.0_mm_catalog "%ETL%\Tomahawk\5.6.0_mm_catalog" /S /E

REM Remove local RELEASE folder
RD /S /Q %~dp0\RELEASE

PAUSE
