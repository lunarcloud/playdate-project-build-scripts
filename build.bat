@echo off
title PlayDate Build Script

:: Variables
SET OUTPUT=%~dp0Output.pdx
SET SOURCE=%~dp0Source
SET CLEAN=1
SET BUILD=1
SET RUN=0
SET STRIP_OPT= 
SET VERBOSE_OPT_COMPILER=-v
SET DETACH_SIMULATOR=0
SET SKIP_UNKNOWN_OPT=

GOTO GetOptions

:CleanTask
title PlayDate Build Script - Cleaning
IF EXIST "%OUTPUT%" (
    echo Deleting old Output.pdx
    rd /S /Q "%OUTPUT%"
) ELSE (
    echo Nothing to clean, skipping.
)
GOTO AfterClean

:BuildTask
title PlayDate Build Script - Building
echo PlayDate Compiler is building Output.pdx from Source.
"%PLAYDATE_SDK_PATH%\bin\pdc.exe" %VERBOSE_OPT_COMPILER% %STRIP_OPT% %SKIP_UNKNOWN_OPT% "%SOURCE%" "%OUTPUT%"
GOTO AfterBuild

:RunTask
title PlayDate Build Script - Run in Simulator
echo Running simulator.
IF EXIST "%OUTPUT%" (
    "%PLAYDATE_SDK_PATH%\bin\PlaydateSimulator.exe" "%OUTPUT%"
) ELSE (
    echo Could not find the Output.pdx to run in the simulator!
)
GOTO AfterRun

:Help
    echo:
    echo Build script for this PlayDate Project.
    echo:
    echo Usage:     build.bat [options]
    echo Options:
    echo -[n]c, --[no-]clean             Clean, i.e. delete, the Output.pdx first (default), or don't."
    echo -[n]b, --[no-]build             Build the sources into the Output.pdx (default), or don't."
    echo -[n]r, --[no-]run               Run the output in the PlayDate Simulator, or don't (default)."
    echo --release                       Strip Debug Symbols."
    echo --quiet                         Don't use verbose flags."
    echo --detach                        Launch Simulator detached from this script (don't wait for it to exit)."
    echo -k, --skip-unknown              When building, skip unrecognized files instead of copying them to the pdx folder."
    echo -cb                             Clean and Build. Don't run."
    echo -cbr                            Clean, Build, and Run. Due to defaults, same as just -r,--run"
    echo -h, --help                      Display this help message."
    echo:

GOTO ErrorEnd

:: Parse Script Arguments, as described in the help message
:GetOptions
if /I "%1" == "-nc" set CLEAN=0
if /I "%1" == "-c" set CLEAN=1
if /I "%1" == "-nb" set BUILD=0
if /I "%1" == "-b" set BUILD=1
if /I "%1" == "-nr" set RUN=0
if /I "%1" == "-r" set RUN=1
if /I "%1" == "-cb" set CLEAN=1 & set BUILD=1 & set RUN=0
if /I "%1" == "-cbr" set CLEAN=1 & set BUILD=1 & set RUN=1
if /I "%1" == "--release" set STRIP_OPT=--strip
if /I "%1" == "--quiet" set VERBOSE_OPT_COMPILER=-q
if /I "%1" == "--detach" set DETACH_SIMULATOR=1
if /I "%1" == "-k" set SKIP_UNKNOWN_OPT=--skip-unknown
if /I "%1" == "--skip-unknown" set SKIP_UNKNOWN_OPT=--skip-unknown
if /I "%1" == "-h" GOTO Help
if /I "%1" == "--help" GOTO Help
if /I "%1" == "/?" GOTO Help
shift
if not "%1" == "" GOTO GetOptions

:: Sanity Checks
IF NOT EXIST "%PLAYDATE_SDK_PATH%" (
    echo PLAYDATE_SDK_PATH environment variable is not set! & GOTO ErrorEnd
)
IF NOT EXIST "%PLAYDATE_SDK_PATH%\bin\pdc.exe" IF %BUILD%==1 (
    echo PlayDate compiler not found at %PLAYDATE_SDK_PATH%\bin\pdc.exe & GOTO ErrorEnd
)
IF NOT EXIST "%PLAYDATE_SDK_PATH%/bin/PlaydateSimulator.exe" IF %RUN%==1 (
    echo PlayDate simulator not found at %PLAYDATE_SDK_PATH%\bin\PlaydateSimulator.exe & GOTO ErrorEnd
)
IF "%CLEAN%|%BUILD%|%RUN%"=="1|0|1" (
    echo Invalid to clean and run without building! & GOTO ErrorEnd
)

IF %CLEAN%==1 ( GOTO CleanTask )
:AfterClean
IF %BUILD%==1 ( GOTO BuildTask )
:AfterBuild
IF %RUN%==1 ( GOTO RunTask )
:AfterRun
GOTO FinishUp

:: Something Went Wrong
:ErrorEnd
SET ERRORLEVEL=1
GOTO FinishUp

:: Return title to normal
:FinishUp
title %cd%
