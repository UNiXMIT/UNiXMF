@echo off
echo ============================================
echo  Enabling Windows Features for IIS/.NET
echo  and Configuring SQL Server Express
echo ============================================
echo.

:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator!
    echo Right-click the .bat file and select "Run as administrator"
    pause
    exit /b 1
)

echo Running as Administrator - OK
echo.

:: ============================================
:: .NET Framework Features
:: ============================================
echo [1/6] Enabling .NET Framework Features...

dism /online /enable-feature /featurename:NetFx4Extended-ASPNET45 /all /norestart
dism /online /enable-feature /featurename:WCF-Services45 /all /norestart
dism /online /enable-feature /featurename:WCF-HTTP-Activation45 /all /norestart
dism /online /enable-feature /featurename:WCF-TCP-PortSharing45 /all /norestart
dism /online /enable-feature /featurename:WCF-Pipe-Activation45 /all /norestart

:: TCP Activation vs Non-HTTP Activation depending on Windows version
ver | findstr /i "10\." >nul
if %errorLevel% == 0 (
    echo Enabling TCP Activation (Windows 10^)...
    dism /online /enable-feature /featurename:WCF-TCP-Activation45 /all /norestart
) else (
    echo Enabling Non-HTTP Activation (Pre-Windows 10^)...
    dism /online /enable-feature /featurename:WCF-NonHTTP-Activation45 /all /norestart
)

:: ============================================
:: IIS - Web Management Tools
:: ============================================
echo.
echo [2/6] Enabling IIS Web Management Tools...

dism /online /enable-feature /featurename:IIS-WebServerManagementTools /all /norestart
dism /online /enable-feature /featurename:IIS-IIS6ManagementCompatibility /all /norestart
dism /online /enable-feature /featurename:IIS-Metabase /all /norestart
dism /online /enable-feature /featurename:IIS-ManagementConsole /all /norestart

:: ============================================
:: IIS - World Wide Web Services
:: ============================================
echo.
echo [3/6] Enabling IIS World Wide Web Services...

:: Application Development Features
dism /online /enable-feature /featurename:IIS-NetFxExtensibility45 /all /norestart
dism /online /enable-feature /featurename:IIS-ASPNET45 /all /norestart

:: Common HTTP Features
dism /online /enable-feature /featurename:IIS-DefaultDocument /all /norestart
dism /online /enable-feature /featurename:IIS-DirectoryBrowsing /all /norestart
dism /online /enable-feature /featurename:IIS-StaticContent /all /norestart

:: Health and Diagnostics
dism /online /enable-feature /featurename:IIS-HttpLogging /all /norestart
dism /online /enable-feature /featurename:IIS-HttpTracing /all /norestart

:: ============================================
:: IIS - Security
:: ============================================
echo.
echo [4/6] Enabling IIS Security Features...

dism /online /enable-feature /featurename:IIS-BasicAuthentication /all /norestart
dism /online /enable-feature /featurename:IIS-WindowsAuthentication /all /norestart

:: ============================================
:: SQL Server Express - Install
:: ============================================
echo.
echo [5/6] Installing SQL Server Express...

choco install sql-server-express

:: ============================================
:: SQL Server Express - Configure NT AUTHORITY\SYSTEM
:: ============================================
echo.
echo [6/6] Configuring SQL Server Express permissions...

:: Check if sqlcmd is available
where sqlcmd >nul 2>&1
if %errorLevel% neq 0 (
    echo WARNING: sqlcmd not found in PATH.
    echo Looking in common SQL Server locations...

    :: Try common install paths
    set SQLCMD=
    for %%P in (
        "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe"
        "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\160\Tools\Binn\sqlcmd.exe"
        "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\150\Tools\Binn\sqlcmd.exe"
        "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\130\Tools\Binn\sqlcmd.exe"
        "C:\Program Files\Microsoft SQL Server\110\Tools\Binn\sqlcmd.exe"
        "C:\Program Files\Microsoft SQL Server\120\Tools\Binn\sqlcmd.exe"
    ) do (
        if exist %%P set SQLCMD=%%P
    )

    if not defined SQLCMD (
        echo ERROR: sqlcmd.exe could not be found. Skipping SQL configuration.
        echo Please run the SQL script manually against .\SQLEXPRESS
        goto :SQLDONE
    )
) else (
    set SQLCMD=sqlcmd
)

echo Using: %SQLCMD%
echo Connecting to .\SQLEXPRESS using Windows Authentication...
echo.

%SQLCMD% -S .\SQLEXPRESS -E -Q ^
"IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'NT AUTHORITY\SYSTEM') BEGIN CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS; PRINT 'Login created.'; END ELSE BEGIN PRINT 'Login already exists.'; END IF IS_SRVROLEMEMBER('sysadmin', 'NT AUTHORITY\SYSTEM') = 0 BEGIN ALTER SERVER ROLE sysadmin ADD MEMBER [NT AUTHORITY\SYSTEM]; PRINT 'sysadmin role added.'; END IF IS_SRVROLEMEMBER('dbcreator', 'NT AUTHORITY\SYSTEM') = 0 BEGIN ALTER SERVER ROLE dbcreator ADD MEMBER [NT AUTHORITY\SYSTEM]; PRINT 'dbcreator role added.'; END"

if %errorLevel% neq 0 (
    echo.
    echo ERROR: SQL script failed. Please check:
    echo   - SQL Server Express is running  ^(services.msc -^> SQL Server ^(SQLEXPRESS^)^)
    echo   - The instance name is .\SQLEXPRESS
    echo   - Your Windows account has sysadmin rights on the instance
) else (
    echo.
    echo SQL configuration completed successfully.
)

:SQLDONE

:: ============================================
:: Done
:: ============================================
echo.
echo ============================================
echo  All steps completed!
echo  A restart may be required to complete.
echo  After restarting the machine. Start an Enterprise Developer 
echo  command prompt as an administrator.At the command prompt, enter: wassetup
echo  When the command has completed its run, you should see the message Operation successfully completed. 
echo ============================================
echo.

set /p REBOOT="Would you like to restart now? (Y/N): "
if /i "%REBOOT%"=="Y" (
    echo Restarting in 10 seconds...
    shutdown /r /t 10
) else (
    echo Please restart your computer manually when ready.
)

pause