@ECHO OFF
CALL "C:\Program Files (x86)\Micro Focus\Enterprise Developer\createenv.bat"
IF EXIST casdumpa.rec (
    ECHO Formatting casdumpa...
    casdup /icasdumpa.rec /fcasdumpa.txt /w /d
)
IF EXIST casdumpb.rec (
    ECHO Formatting casdumpb...
    casdup /icasdumpb.rec /fcasdumpb.txt /w /d
)
IF EXIST casdumpx.rec (
    ECHO Formatting casdumpx...
    casdup /icasdumpx.rec /fcasdumpx.txt /w /d
)
IF EXIST casauxta.rec (
    ECHO Formatting casauxta...
    casdup /icasauxta.rec /fcasauxta.txt /w /d
)
IF EXIST casauxtb.rec (
    ECHO Formatting casauxtb...
    casdup /icasauxtb.rec /fcasauxtb.txt /w /d
)
ECHO Formatting Complete!