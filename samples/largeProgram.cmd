@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    set numFiles=10
) else (
    set numFiles=%~1
)

for /L %%i in (1,1,%numFiles%) do (
    set fileName=program%%i.cbl
    (
    echo        identification division.
    echo        program-id. program%%i.
    echo.
    echo        environment division.
    echo        configuration section.
    echo.
    echo        data division.
    echo        working-storage section.
    echo.
    echo        procedure division.
    echo.
    echo            goback.
    echo.
    echo        end program program%%i.
    ) > !fileName!
)

echo Created %numFiles% files.
endlocal