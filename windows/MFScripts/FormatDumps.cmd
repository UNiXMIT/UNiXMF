@ECHO OFF
CALL "C:\Program Files (x86)\Micro Focus\Enterprise Developer\createenv.bat"
set DUMPS=0
IF EXIST casdumpa.rec (
    set DUMPS=1
    ECHO Formatting casdumpa...
    casdup /icasdumpa.rec /fcasdumpa.txt /w /d
)
IF EXIST casdumpb.rec (
    set DUMPS=1
    ECHO Formatting casdumpb...
    casdup /icasdumpb.rec /fcasdumpb.txt /w /d
)
IF EXIST casdumpx.rec (
    set DUMPS=1
    ECHO Formatting casdumpx...
    casdup /icasdumpx.rec /fcasdumpx.txt /w /d
)
IF EXIST casauxta.rec (
    set DUMPS=1
    ECHO Formatting casauxta...
    casdup /icasauxta.rec /fcasauxta.txt /w /d
)
IF EXIST casauxtb.rec (
    set DUMPS=1
    ECHO Formatting casauxtb...
    casdup /icasauxtb.rec /fcasauxtb.txt /w /d
)
IF %DUMPS%==1 (
    ECHO Formatting Complete!
) ELSE IF %DUMPS%==0 (
    ECHO No Files Found!
)