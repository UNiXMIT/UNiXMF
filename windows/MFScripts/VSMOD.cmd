@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

SET "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"

IF NOT EXIST "%VSWHERE%" (
    ECHO vswhere.exe not found
    EXIT /b 1
)

FOR /F "USEBACKQ TOKENS=*" %%I IN (`"%VSWHERE%" -latest -property installationPath`) do (
    set "VSInstallPath=%%I"
)

FOR /F "USEBACKQ TOKENS=*" %%X IN (`"%VSWHERE%" -latest -property displayName`) do (
    set "VSName=%%X"
)

if "%VSInstallPath%"=="" (
    echo Visual Studio not found
    exit /b 1
)

"C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup" modify --passive --norestart --downloadThenInstall --installPath "%VSInstallPath%" --add Microsoft.Net.Component.4.5.TargetingPack --add Microsoft.Net.Component.4.5.2.TargetingPack --add Microsoft.Net.Component.4.7.2.TargetingPack --add Microsoft.VisualStudio.Component.Debugger.JustInTime --add Microsoft.VisualStudio.Component.GraphDocument --add Microsoft.VisualStudio.Component.NuGet --add Microsoft.VisualStudio.Component.Windows10SDK.18362 --add Microsoft.VisualStudio.Component.DockerTools --add Microsoft.VisualStudio.Component.VisualStudioData --add Microsoft.VisualStudio.Component.Web --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.Azure --add Microsoft.VisualStudio.Component.Wcf.Tooling --add Microsoft.VisualStudio.Component.SQL.SSDT --add Microsoft.VisualStudio.Workload.NetCoreTools