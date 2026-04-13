#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'
$LogFile = "$PSScriptRoot\esNETsetup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $entry = "[$(Get-Date -Format 'HH:mm:ss')] [$Level] $Message"
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN"  { "Yellow" }
        default { "Cyan" }
    }
    Write-Host $entry -ForegroundColor $color
    Add-Content -Path $LogFile -Value $entry
}

function Enable-Feature {
    param([string]$Name)
    try {
        $result = Enable-WindowsOptionalFeature -Online -FeatureName $Name -All -NoRestart
        Write-Log "Enabled: $Name"
        return $result.RestartNeeded
    } catch {
        Write-Log "Failed to enable ${Name}: $_" "WARN"
        return $false
    }
}

$restartNeeded = $false

# ── .NET / WCF Features ────────────────────────────────────────────────────────
Write-Log "[1/6] Enabling .NET Framework Features..."

$dotnetFeatures = @(
    "NetFx4Extended-ASPNET45",
    "WCF-Services45",
    "WCF-HTTP-Activation45",
    "WCF-TCP-PortSharing45",
    "WCF-Pipe-Activation45"
)

foreach ($f in $dotnetFeatures) {
    $restartNeeded = (Enable-Feature $f) -or $restartNeeded
}

$build = [System.Environment]::OSVersion.Version.Build
$tcpFeature = if ($build -ge 10240) { "WCF-TCP-Activation45" } else { "WCF-NonHTTP-Activation45" }
Write-Log "Using activation feature: $tcpFeature (OS build $build)"
$restartNeeded = (Enable-Feature $tcpFeature) -or $restartNeeded

# ── IIS Management Tools ───────────────────────────────────────────────────────
Write-Log "[2/6] Enabling IIS Web Management Tools..."

$iisManagement = @(
    "IIS-WebServerManagementTools",
    "IIS-IIS6ManagementCompatibility",
    "IIS-Metabase",
    "IIS-ManagementConsole"
)

foreach ($f in $iisManagement) {
    $restartNeeded = (Enable-Feature $f) -or $restartNeeded
}

# ── IIS World Wide Web Services ────────────────────────────────────────────────
Write-Log "[3/6] Enabling IIS World Wide Web Services..."

$iisWeb = @(
    "IIS-NetFxExtensibility45",
    "IIS-ASPNET45",
    "IIS-DefaultDocument",
    "IIS-DirectoryBrowsing",
    "IIS-StaticContent",
    "IIS-HttpLogging",
    "IIS-HttpTracing"
)

foreach ($f in $iisWeb) {
    $restartNeeded = (Enable-Feature $f) -or $restartNeeded
}

# ── IIS Security ───────────────────────────────────────────────────────────────
Write-Log "[4/6] Enabling IIS Security Features..."

$iisSecurity = @(
    "IIS-BasicAuthentication",
    "IIS-WindowsAuthentication"
)

foreach ($f in $iisSecurity) {
    $restartNeeded = (Enable-Feature $f) -or $restartNeeded
}

# ── SQL Server ────────────────────────────────────────────────────────────────── 
Write-Log "[5/6] Installing SQL Server..."

if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Log "Chocolatey not found. Installing..." "WARN"
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } catch {
        Write-Log "Failed to install Chocolatey: $_" "ERROR"
        exit 1
    }
}

try {
	choco feature enable -n=allowGlobalConfirmation
    choco install sql-server-2022 -y -r
    if ($LASTEXITCODE -ne 0) { throw "choco exited with code $LASTEXITCODE" }
    Write-Log "SQL Server installed."
} catch {
    Write-Log "SQL Server installation failed: $_" "ERROR"
    exit 1
}

# ── SQL Server Configuration ───────────────────────────────────────────────────
Write-Log "[6/6] Configuring SQL Server permissions..."

$sqlcmd = $null

$inPath = Get-Command sqlcmd -ErrorAction SilentlyContinue
if ($inPath) {
    $sqlcmd = $inPath.Source
    Write-Log "Found sqlcmd in PATH: $sqlcmd"
}

if (-not $sqlcmd) {
    $found = Get-ChildItem "C:\Program Files\Microsoft SQL Server" -Recurse -Filter "sqlcmd.exe" -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending |
        Select-Object -First 1
    if ($found) {
        $sqlcmd = $found.FullName
        Write-Log "Found sqlcmd at: $sqlcmd"
    }
}

if (-not $sqlcmd) {
    Write-Log "sqlcmd.exe not found. Skipping SQL configuration - try running manually" "WARN"
} else {
    $sqlFile = [System.IO.Path]::GetTempFileName() + ".sql"
    try {
        $sqlLines = @(
            "IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'NT AUTHORITY\SYSTEM')",
            "BEGIN",
            "    CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS;",
            "    PRINT 'Login created.';",
            "END",
            "ELSE PRINT 'Login already exists.';",
            "",
            "IF IS_SRVROLEMEMBER('sysadmin', 'NT AUTHORITY\SYSTEM') = 0",
            "BEGIN",
            "    ALTER SERVER ROLE sysadmin ADD MEMBER [NT AUTHORITY\SYSTEM];",
            "    PRINT 'sysadmin role added.';",
            "END",
            "",
            "IF IS_SRVROLEMEMBER('dbcreator', 'NT AUTHORITY\SYSTEM') = 0",
            "BEGIN",
            "    ALTER SERVER ROLE dbcreator ADD MEMBER [NT AUTHORITY\SYSTEM];",
            "    PRINT 'dbcreator role added.';",
            "END"
        )
        [System.IO.File]::WriteAllLines($sqlFile, $sqlLines, [System.Text.Encoding]::UTF8)
        Write-Log "SQL script written to: $sqlFile"

        & $sqlcmd -E -i $sqlFile
        if ($LASTEXITCODE -ne 0) { throw "sqlcmd failed with exit code $LASTEXITCODE" }
        Write-Log "SQL configuration completed successfully."
    } catch {
        Write-Log "SQL configuration failed: $_" "ERROR"
        Write-Log "Check: SQL Server service is running, instance name is correct, your account has sysadmin rights." "WARN"
    } finally {
        if (Test-Path $sqlFile) { Remove-Item $sqlFile -Force }
    }
}

# ── Done ───────────────────────────────────────────────────────────────────────
Write-Log ""
Write-Log "============================================"
Write-Log " All steps completed! Log saved to: $LogFile"
Write-Log " After restarting: Open an Enterprise Developer command"
Write-Log " prompt as Administrator and run: wassetup"
Write-Log "============================================"

if ($restartNeeded) {
    $reboot = Read-Host "A restart is required. Restart now? (Y/N)"
    if ($reboot -ieq "Y") {
        Write-Log "Rebooting..."
        Restart-Computer -Force
    } else {
        Write-Log "Please restart manually before running wassetup." "WARN"
    }
} else {
    Write-Log "No restart flagged - but one may still be advisable."
    Read-Host "Press Enter to exit"
}