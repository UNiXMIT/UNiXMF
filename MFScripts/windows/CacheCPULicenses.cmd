@ECHO OFF
echo cachecpulicenses = 1 >> "\ProgramData\Micro Focus\ces.ini"
sc mfcesd stop
sc mfcesd start