#Requires -RunAsAdministrator
<#
.SYNOPSIS  
    Full Active Directory + Micro Focus Enterprise Server setup.
.NOTES
    Stage 1: Sets static IP, installs AD DS/DNS, promotes forest DC, reboots.
    Stage 2: Verifies AD DS, creates MF partition, runs ES LDAP setup, configures ESM.

    169.254.169.253 is the AWS-provided Route 53 resolver available in VPCs with DNS support enabled. It forwards to the VPC's configured DNS servers, and is recommended as the primary forwarder for reliability and to ensure resolution of AWS-specific names (e.g. instance metadata). Additional public DNS servers are included as fallbacks.
    1.1.1.1 and 8.8.8.8 are public DNS servers that can be used as secondary forwarders in case the AWS resolver is unavailable for any reason.
#>

# =============================================================================
# CONFIG
# =============================================================================
$DomainName       = "corp.example.com"
$NetBIOSName      = "CORP"
$DomainDN         = "DC=corp,DC=example,DC=com"
$Partition        = "Micro Focus"
$PartitionDN      = "CN=$Partition,$DomainDN"
$AdminPassword    = "strongPassword#123"
$DNSForwarder     = @("169.254.169.253", "1.1.1.1", "8.8.8.8")
$ESBaseURL        = "http://localhost:10086"
$regPath          = "HKLM:\Software\SetupAD"
# =============================================================================

Set-StrictMode -Version Latest
Set-Location $PSScriptRoot
$ScriptPath= $MyInvocation.MyCommand.Path
$ErrorActionPreference = "Stop"

function Write-Step { param([string]$Msg) Write-Host "`n[$(Get-Date -f 'HH:mm:ss')] $Msg`n" -ForegroundColor Cyan }
function Write-OK   { param([string]$Msg) Write-Host "  OK  $Msg`n" -ForegroundColor Green }
function Write-Warn { param([string]$Msg) Write-Host "  !!  $Msg`n" -ForegroundColor Yellow }

function Get-ResumeStage {
    $item = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
    if ($item -and $item.PSObject.Properties.Match('ResumeStage')) {
        return [int]$item.ResumeStage
    } else {
        return 1
    }
}

function Set-ResumeStage([int]$Stage) {
    if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
    Set-ItemProperty -Path $regPath -Name "ResumeStage" -Value $Stage
}

function Clear-ResumeStage {
    Remove-Item -Path $regPath -Force -ErrorAction SilentlyContinue
}

function Invoke-RebootAndResume([int]$ResumeAtStage) {
    Set-ResumeStage $ResumeAtStage
    Write-Warn "A reboot is required to continue." -ForegroundColor Yellow
    Write-Warn "After reboot, login as $NetBIOSName\Administrator." -ForegroundColor Yellow
    Write-Warn "Re-run this script ($ScriptPath) to complete setup. It will automatically resume at stage 2." -ForegroundColor Yellow
    Read-Host "Press Enter to reboot now"
    Restart-Computer -Force
    exit
}

$currentStage = Get-ResumeStage

# =============================================================================
# STAGE 1 - AD DS + DNS Setup
# =============================================================================
if ($currentStage -eq 1) {
    # STAGE 1 - STEP 1: Detect and remove ADLDS if present
    Write-Step "1/6 - Checking for ADLDS instances"
    $adldsFeature = Get-WindowsFeature -Name ADLDS
    if ($adldsFeature.Installed -eq $true) {
        $instanceName = "ADLDS"
        Stop-Service "ADAM_$instanceName" -Force -ErrorAction SilentlyContinue
        C:\Windows\ADAM\adamuninstall.exe /i:$instanceName /q /force
        Start-Sleep -Seconds 5
        Remove-WindowsFeature -Name ADLDS
        Remove-WindowsFeature -Name "RSAT-AD-LDS" -ErrorAction SilentlyContinue
        Write-OK "ADLDS removal completed!"
    } else {
        Write-OK "ADLDS feature is not installed. Nothing to remove."
    }

    # STAGE 1 - STEP 2: Check hostname
    Write-Step "2/6 - Checking hostname"
    Write-OK "Hostname: $env:COMPUTERNAME  will be promoted as $env:COMPUTERNAME.$DomainName"

    # STAGE 1 - STEP 3: Detect private IP
    Write-Step "3/6 - Detecting EC2 private IP"
    try {
        $Token     = Invoke-RestMethod -Uri "http://169.254.169.254/latest/api/token" `
                            -Method PUT -Headers @{ "X-aws-ec2-metadata-token-ttl-seconds" = "21600" }
        $PrivateIP = Invoke-RestMethod -Uri "http://169.254.169.254/latest/meta-data/local-ipv4" `
                            -Headers @{ "X-aws-ec2-metadata-token" = $Token }
    } catch {
        Write-Warn "IMDS unreachable - falling back to adapter IP."
        $PrivateIP = (Get-NetIPAddress -AddressFamily IPv4 |
                        Where-Object { $_.IPAddress -notmatch "^127\." } |
                        Select-Object -First 1).IPAddress
    }
    Write-OK "Private IP: $PrivateIP"

    # STAGE 1 - STEP 4: Configure static IP and DNS
    Write-Step "4/6 - Configuring static IP and DNS"
    $Adapter   = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.Name -notmatch "Loopback" } | Select-Object -First 1
    $Idx       = $Adapter.InterfaceIndex

    $ExistingIP = Get-NetIPAddress -InterfaceIndex $Idx -AddressFamily IPv4 -ErrorAction SilentlyContinue
    if ($ExistingIP) { $PrefixLen = $ExistingIP.PrefixLength } else { $PrefixLen = 24 }

    $ExistingRoute = Get-NetRoute -InterfaceIndex $Idx -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue
    if ($ExistingRoute) { $GW = $ExistingRoute.NextHop } else { $GW = $PrivateIP -replace '\.\d+$', '.1' }

    Set-NetIPInterface  -InterfaceIndex $Idx -Dhcp Disabled -ErrorAction SilentlyContinue
    Remove-NetIPAddress -InterfaceIndex $Idx -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetRoute     -InterfaceIndex $Idx -DestinationPrefix "0.0.0.0/0" -Confirm:$false -ErrorAction SilentlyContinue
    New-NetIPAddress    -InterfaceIndex $Idx -IPAddress $PrivateIP -PrefixLength $PrefixLen -DefaultGateway $GW | Out-Null
    Set-DnsClientServerAddress -InterfaceIndex $Idx -ServerAddresses (@("127.0.0.1") + $DNSForwarder)
    Write-OK "Static IP: $PrivateIP/$PrefixLen  GW: $GW  DNS: 127.0.0.1, $($DNSForwarder -join ', ')"

    # STAGE 1 - STEP 5: Install roles + promote
    Write-Step "5/6 - Installing AD DS / DNS roles"
    Install-WindowsFeature -Name "AD-Domain-Services","DNS","RSAT-AD-Tools","RSAT-DNS-Server" -IncludeManagementTools | Out-Null
    Write-OK "Features installed."

    # STAGE 1 - STEP 6: Promote to new AD forest
    Write-Step "6/6 - Promoting to new AD forest ($DomainName)"
    Import-Module ADDSDeployment
    Install-ADDSForest `
        -DomainName                    $DomainName `
        -DomainNetbiosName             $NetBIOSName `
        -DomainMode                    "WinThreshold" `
        -ForestMode                    "WinThreshold" `
        -SafeModeAdministratorPassword (ConvertTo-SecureString $AdminPassword -AsPlainText -Force) `
        -InstallDns -Force -NoRebootOnCompletion:$true
    Write-OK "Forest promotion complete."

    Invoke-RebootAndResume -ResumeAtStage 2
}

# =============================================================================
# STAGE 2 - AD + ED/ES ESM Configuration
# =============================================================================
if ($currentStage -eq 2) {
    # STAGE 2 - STEP 1: Verify AD DS is running and responsive 
    Write-Step "1/4 - Verifying AD DS"
    $svc = Get-Service -Name "NTDS" -ErrorAction SilentlyContinue
    if (-not $svc -or $svc.Status -ne "Running") {
        Write-Error "NTDS is not running. Ensure DC promotion reboot has completed."
        exit 1
    }
    Write-OK "AD DS running."

    # STAGE 2 - STEP 2: Create MF application partition container
    Write-Step "2/4 - Creating '$Partition' container"
    Import-Module ActiveDirectory
    $existing = Get-ADObject -Filter { DistinguishedName -eq $PartitionDN } -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Warn "Container already exists, skipping."
    } else {
        New-ADObject -Name $Partition -Type "container" -Path $DomainDN
        Write-OK "Container created at: $PartitionDN"
    }

    # STAGE 2 - STEP 3: ES LDAP setup
    Write-Step "3/4 - Running ES LDAP setup"
    Copy-Item "C:\Program Files (x86)\Micro Focus\Enterprise Developer\etc\cas\dfhdrdat" -Destination $PSScriptRoot
    $ESLdapCmd = "C:\Program Files (x86)\Micro Focus\Enterprise Developer\bin\es-ldap-setup.cmd"
    (Get-Content $ESLdapCmd) -Replace 'pause', ' ' | Set-Content $ESLdapCmd
    & $ESLdapCmd /ad - - "$PartitionDN" localhost:389

    # STAGE 2 - STEP 4: Configure ESM module for AD
    Write-Step "4/4 - Configuring ESM module"

    $LDAPConfig = "[LDAP]`nbind=negotiate`nBASE=$PartitionDN`nuser class=microfocus-MFDS-User`nuser container=CN=Enterprise Server Users`ngroup container=CN=Enterprise Server User Groups`nresource container=CN=Enterprise Server Resources`n`n[Operation]`nset login count=yes`nsignon attempts=3`n`n[Verify]`nMode=MF-hash`n`n[Trace]`nModify=y`nRule=y`nGroups=y`nSearch=y`nBind=n`nTrace1=verify:*:debug`nTrace2=auth:*:*:**:debug"

    $ESUser = "SYSAD"
    $ESPass = "SYSAD"

    $LogonBody = @{ mfUser = $ESUser; mfPassword = $ESPass } | ConvertTo-Json -Compress
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

    $logonResponse = Invoke-RestMethod -Method Post `
        -Uri "$ESBaseURL/logon" `
        -ContentType "application/json" `
        -Headers @{
            "accept" = "application/json"
            "X-Requested-With" = "API"
            "Origin" = $ESBaseURL
        } `
        -Body $LogonBody  `
        -WebSession $session
    Write-OK "Logon response: $logonResponse"

    $ESMBody = @{
        Name           = "ADESM"
        Description    = "AD ESM"
        Module         = "mldap_esm"
        ConnectionPath = "localhost:389"
        AuthorizedID   = "$NetBIOSName\Administrator"
        Password       = $AdminPassword
        Enabled        = $true
        CacheLimit     = 1024
        CacheTTL       = 600
        Config         = $LDAPConfig
    } | ConvertTo-Json -Compress

    $NativeBody = @{
        CN                  = "ADESM"
        description         = "AD ESM"
        mfESMModule         = "mldap_esm"
        mfESMConnectionPath = "localhost:389"
        mfESMID             = "$NetBIOSName\Administrator"
        mfESMPwd            = $AdminPassword
        mfESMStatus         = "Enabled"
        mfESMCacheLimit     = 1024
        mfESMCacheTTL       = 600
        mfConfig            = $LDAPConfig
    } | ConvertTo-Json -Compress

    Invoke-RestMethod -Method Post `
        -Uri "$ESBaseURL/server/v1/config/esm" `
        -ContentType "application/json" `
        -WebSession $session `
        -Body $ESMBody
    
    Invoke-RestMethod -Method Post `
        -Uri "$ESBaseURL/native/v1/security/127.0.0.1/86/esm" `
        -ContentType "application/json" `
        -WebSession $session `
        -Body $NativeBody
}

# =============================================================================
# DONE
# =============================================================================
Clear-ResumeStage
Write-Host "==============DONE==============" -ForegroundColor Green
Write-Host "AD + ESM configuration complete." -ForegroundColor Green