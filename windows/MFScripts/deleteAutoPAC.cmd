@ECHO OFF
TASKKILL -f -im cassi.exe & TASKKILL -f -im casmgr.exe & TASKKILL -f -im castsc.exe & TASKKILL -f -im cascd.exe & TASKKILL -F -IM MFCS.EXE & TASKKILL -F -IM CASTRC.EXE & TASKKILL -F -IM CASDBC.EXE & TASKKILL -F -IM CASTMC.EXE & TASKKILL -F -IM CASMQB.EXE & TASKKILL -F -IM CASPRT.EXE
TASKKILL -f -im redis-server.exe

ECHO All running region processes killed....

rd \tutorials\ACCT /Q /S
rd \MFSamples\JCL /Q /S
rd \MFSamples\MFBSI /Q /S
:: rd \MFSamples\MQ /Q /S
:: rd \MFSamples\ACCTPLI /Q /S
:: rd \MFSamples\JCLPLI /Q /S
rd \WORK /Q /S

ECHO All region directories removed...

ECHO Remember to delete the regions via ESMAC or ESCWA, including the PAC setup..