#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Single-server SCOM 2025 setup on Windows Server 2022/2025
    Supports automatic resume after reboot.
.NOTES
    Prerequisites:
      - Machine is domain-joined
      - Run as domain admin
      - SCOM 2025 ISO already downloaded and mounted (or extracted)
      - SQL Server Reporting Services 2022 installer downloaded separately
    
    Adjust the variables in the CONFIG section before running.
#>

# ============================================================
# CONFIG — edit these before running
# ============================================================
$SCOMSetupPath       = "D:\SCOM2025\setup.exe"
$SSRSInstallerPath   = "C:\Installers\SQLServerReportingServices.exe"
$ManagementGroupName = "SCOM-LAB"
$SQLInstance         = "$env:COMPUTERNAME"
$SQLInstancePort     = "1433"
$OpsDBName           = "OperationsManager"
$DWDBName            = "OperationsManagerDW"
$SRSInstance         = "$env:COMPUTERNAME"
$UseNamedAccounts    = $false
$DataReaderUser      = "DOMAIN\scom-datareader"
$DataReaderPassword  = "P@ssword123"
$DataWriterUser      = "DOMAIN\scom-datawriter"
$DataWriterPassword  = "P@ssword123"

# ============================================================
# RESUME LOGIC
# ============================================================
$RegPath     = "HKLM:\SOFTWARE\SCOMSetup"
$ScriptPath  = $MyInvocation.MyCommand.Path

function Get-ResumeStep {
    $val = (Get-ItemProperty -Path $RegPath -ErrorAction SilentlyContinue).ResumeStep
    return if ($val) { [int]$val } else { 1 }
}

function Set-ResumeStep([int]$Step) {
    if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
    Set-ItemProperty -Path $RegPath -Name "ResumeStep" -Value $Step
}

function Clear-ResumeStep {
    Remove-Item -Path $RegPath -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" `
        -Name "SCOMSetupResume" -ErrorAction SilentlyContinue
}

function Invoke-RebootAndResume([int]$ResumeAtStep) {
    Write-Host "Reboot required. Script will automatically resume at step $ResumeAtStep after restart." -ForegroundColor Yellow
    Set-ResumeStep $ResumeAtStep
    Start-Sleep -Seconds 3
    Restart-Computer -Force
    exit
}

$currentStep = Get-ResumeStep

if ($currentStep -gt 1) {
    Write-Host "`nResuming SCOM setup from step $currentStep..." -ForegroundColor Cyan
}

# ============================================================
# STEP 1 — Install Windows Features / IIS Prerequisites
# ============================================================
if ($currentStep -le 1) {
    Write-Host "`n[1/6] Installing Windows Features..." -ForegroundColor Cyan

    Add-WindowsFeature `
        NET-WCF-HTTP-Activation45, `
        Web-Static-Content, `
        Web-Default-Doc, `
        Web-Dir-Browsing, `
        Web-Http-Errors, `
        Web-Http-Logging, `
        Web-Request-Monitor, `
        Web-Filtering, `
        Web-Stat-Compression, `
        Web-Mgmt-Console, `
        Web-Metabase, `
        Web-Asp-Net, `
        Web-Windows-Auth, `
        NET-Framework-Core, `
        NET-Framework-45-Core `
        -Restart:$false

    Write-Host "Windows features installed." -ForegroundColor Green
}

# ============================================================
# STEP 2 — Install SQL Server 2022 via Chocolatey
# ============================================================
if ($currentStep -le 2) {
    Write-Host "`n[2/6] Installing SQL Server 2022 via Chocolatey..." -ForegroundColor Cyan

    choco install sql-server-2022 -y --params "'/SQLCOLLATION:SQL_Latin1_General_CP1_CI_AS /TCPENABLED:1'"

    if ($LASTEXITCODE -notin @(0, 3010)) {
        Write-Error "SQL Server install failed with exit code $LASTEXITCODE"
        exit 1
    }

    choco install sql-server-management-studio -y
    choco install sqlserver-odbcdriver -y
    choco install msoledbsql -y

    Write-Host "SQL Server 2022 installed." -ForegroundColor Green
}

# ============================================================
# STEP 3 — Install SQL Server Reporting Services
# ============================================================
if ($currentStep -le 3) {
    Write-Host "`n[3/6] Installing SQL Server Reporting Services..." -ForegroundColor Cyan

    if (-not (Test-Path $SSRSInstallerPath)) {
        Write-Error "SSRS installer not found at $SSRSInstallerPath"
        Write-Error "Download from: https://www.microsoft.com/en-us/download/details.aspx?id=104502"
        exit 1
    }

    Start-Process -FilePath $SSRSInstallerPath `
        -ArgumentList "/quiet /IAcceptLicenseTerms /Edition=Eval" `
        -Wait -NoNewWindow

    $rsConfig = "C:\Program Files\Microsoft SQL Server Reporting Services\Shared Tools\rsconfig.exe"
    if (Test-Path $rsConfig) {
        & $rsConfig -c -s $env:COMPUTERNAME -d ReportServer -a Windows -i SSRS
    }

    Write-Host "SSRS installed." -ForegroundColor Green
}

# ============================================================
# STEP 4 — Reboot if pending
# ============================================================
if ($currentStep -le 4) {
    Write-Host "`n[4/6] Checking for pending reboot..." -ForegroundColor Cyan

    $pendingReboot = (Get-ItemProperty `
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing" `
        -ErrorAction SilentlyContinue).RebootPending

    if ($pendingReboot) {
        # Resume at step 5 (skip the reboot check) after restart
        Invoke-RebootAndResume -ResumeAtStep 5
    } else {
        Write-Host "No reboot required, continuing..." -ForegroundColor Green
    }
}

# ============================================================
# STEP 5 — Install SCOM 2025
# ============================================================
if ($currentStep -le 5) {
    Write-Host "`n[5/6] Installing SCOM 2025 (this takes 10-20 minutes)..." -ForegroundColor Cyan

    if (-not (Test-Path $SCOMSetupPath)) {
        Write-Error "SCOM setup.exe not found at $SCOMSetupPath"
        exit 1
    }

    $scomArgs = @(
        "/silent",
        "/install",
        "/components:OMServer,OMConsole,OMWebConsole,OMReporting",
        "/ManagementGroupName:$ManagementGroupName",
        "/SqlServerInstance:$SQLInstance",
        "/SqlInstancePort:$SQLInstancePort",
        "/DatabaseName:$OpsDBName",
        "/DWSqlServerInstance:$SQLInstance",
        "/DWSqlInstancePort:$SQLInstancePort",
        "/DWDatabaseName:$DWDBName",
        "/SRSInstance:$SRSInstance",
        "/WebConsoleAuthorizationMode:Mixed",
        "/SendODRReports:0",
        "/EnableErrorReporting:Never",
        "/SendCEIPReports:0",
        "/UseMicrosoftUpdate:0",
        "/AcceptEndUserLicenseAgreement:1"
    )

    if ($UseNamedAccounts) {
        $scomArgs += "/DataReaderUser:$DataReaderUser"
        $scomArgs += "/DataReaderPassword:$DataReaderPassword"
        $scomArgs += "/DataWriterUser:$DataWriterUser"
        $scomArgs += "/DataWriterPassword:$DataWriterPassword"
    } else {
        $scomArgs += "/UseLocalSystemActionAccount"
        $scomArgs += "/UseLocalSystemDASAccount"
    }

    $process = Start-Process -FilePath $SCOMSetupPath -ArgumentList $scomArgs -Wait -PassThru -NoNewWindow

    if ($process.ExitCode -ne 0) {
        Write-Error "SCOM setup failed with exit code $($process.ExitCode)"
        Write-Error "Check log: $env:LOCALAPPDATA\SCOM\Logs\OpsMgrSetupWizard.log"
        exit 1
    }

    Write-Host "SCOM 2025 installed successfully!" -ForegroundColor Green
}

# ============================================================
# STEP 6 — Post-install checks
# ============================================================
if ($currentStep -le 6) {
    Write-Host "`n[6/6] Post-install verification..." -ForegroundColor Cyan

    $services = @("HealthService", "omsdk", "cshost")

    foreach ($svc in $services) {
        $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($s) {
            $color = if ($s.Status -eq 'Running') { 'Green' } else { 'Red' }
            Write-Host "  $($s.DisplayName): $($s.Status)" -ForegroundColor $color
        } else {
            Write-Warning "  Service '$svc' not found"
        }
    }
}

# ============================================================
# DONE — clean up resume state
# ============================================================
Clear-ResumeStep

Write-Host "`n=====================================================" -ForegroundColor Cyan
Write-Host " SCOM 2025 Setup Complete!" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host " Operations Console: Start Menu > Operations Manager Console"
Write-Host " Web Console:        http://$($env:COMPUTERNAME)/OperationsManager"
Write-Host " Setup log:          $env:LOCALAPPDATA\SCOM\Logs\OpsMgrSetupWizard.log"
Write-Host ""
Write-Host " REMINDER: Apply your license key via:" -ForegroundColor Yellow
Write-Host "   Console > Help > About > Activate" -ForegroundColor Yellow