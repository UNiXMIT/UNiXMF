#Requires -RunAsAdministrator
<#
.SYNOPSIS  Full Active Directory + Micro Focus Enterprise Server setup.
.NOTES
    Stage 1: Sets static IP, installs AD DS/DNS, promotes forest DC, reboots.
    Stage 2: Verifies AD DS, creates MF partition, runs ES LDAP setup, configures ESM.
#>

# =============================================================================
# CONFIG
# =============================================================================
$DomainName       = "corp.example.com"
$NetBIOSName      = "CORP"
$AdminPassword    = "strongPassword#123"
$DNSForwarder     = @("169.254.169.253", "1.1.1.1", "8.8.8.8")
$DomainDN         = "DC=corp,DC=example,DC=com"
$Partition        = "Micro Focus"
$PartitionDN      = "CN=$Partition,$DomainDN"
$ESBaseURL        = "http://localhost:10086"
$resumeFile       = Join-Path $PSScriptRoot ".SetupADResume"
$ScriptPath       = $MyInvocation.MyCommand.Path
# =============================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Write-Step { param([string]$Msg) Write-Host "`n[$(Get-Date -f 'HH:mm:ss')] $Msg" -ForegroundColor Cyan }
function Write-OK   { param([string]$Msg) Write-Host "  OK  $Msg" -ForegroundColor Green }
function Write-Warn { param([string]$Msg) Write-Host "  !!  $Msg" -ForegroundColor Yellow }

# STAGE 1
if (-not (Test-Path $resumeFile)) {
    # 0 - Detect and remove ADLDS
    Write-Step "0/5 - Checking for ADLDS instances"
    $adldsFeature = Get-WindowsFeature -Name ADLDS
    if ($adldsFeature.Installed -eq $true) {
        $instanceName = "ADLDS"
        Stop-Service "ADAM_$instanceName" -Force -ErrorAction SilentlyContinue
        C:\Windows\ADAM\adamuninstall.exe /i:$instanceName /q /force
        Start-Sleep -Seconds 5
        Write-Host "Removing AD LDS feature..." -ForegroundColor Cyan
        Remove-WindowsFeature -Name ADLDS
        Write-Host "Removing AD LDS RSAT tools..." -ForegroundColor Cyan
        Remove-WindowsFeature -Name "RSAT-AD-LDS" -ErrorAction SilentlyContinue
        Write-OK "ADLDS removal completed!"
    } else {
        Write-OK "ADLDS feature is not installed. Nothing to remove."
    }

    # 1 - Hostname
    Write-Step "1/5 - Checking hostname"
    Write-OK "Hostname: $env:COMPUTERNAME  will be promoted as $env:COMPUTERNAME.$DomainName"

    # 2 - Detect private IP (IMDSv2 with fallback)
    Write-Step "2/5 - Detecting EC2 private IP"
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

    # 3 - Static IP + DNS
    Write-Step "3/5 - Configuring static IP and DNS"
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

    # 4 - Install roles + promote
    Write-Step "4/5 - Installing AD DS / DNS roles"
    Install-WindowsFeature -Name "AD-Domain-Services","DNS","RSAT-AD-Tools","RSAT-DNS-Server" -IncludeManagementTools | Out-Null
    Write-OK "Features installed."

    Write-Step "4b/5 - Promoting to new AD forest ($DomainName)"
    Import-Module ADDSDeployment
    Install-ADDSForest `
        -DomainName                    $DomainName `
        -DomainNetbiosName             $NetBIOSName `
        -DomainMode                    "WinThreshold" `
        -ForestMode                    "WinThreshold" `
        -SafeModeAdministratorPassword (ConvertTo-SecureString $AdminPassword -AsPlainText -Force) `
        -InstallDns -Force -NoRebootOnCompletion:$true
    Write-OK "Forest promotion complete."

    New-Item -Path $resumeFile -ItemType File | Out-Null

    Write-Host "`nAfter reboot, log back in as $NetBIOSName\Administrator." -ForegroundColor Yellow
    Write-Host "Execute the script ($ScriptPath) again to finish the setup." -ForegroundColor Yellow
    Write-Host "Rebooting in 30 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    Restart-Computer -Force
}

# STAGE 2
if (Test-Path $resumeFile) {
    # 1 - Verify AD DS
    Write-Step "1/4 - Verifying AD DS"
    $svc = Get-Service -Name "NTDS" -ErrorAction SilentlyContinue
    if (-not $svc -or $svc.Status -ne "Running") {
        Write-Error "NTDS is not running. Ensure DC promotion reboot has completed."
        exit 1
    }
    Write-OK "AD DS running."

    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters" -Name "LDAPServerIntegrity" -Value 0 -Type DWord -Force

    Import-Module ActiveDirectory

    # 2 - Create MF application partition container
    Write-Step "2/4 - Creating '$Partition' container"
    $existing = Get-ADObject -Filter { DistinguishedName -eq $PartitionDN } -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Warn "Container already exists, skipping."
    } else {
        New-ADObject -Name $Partition -Type "container" -Path $DomainDN
        Write-OK "Container created at: $PartitionDN"
    }

    # 3 - ES LDAP setup
    Write-Step "3/4 - Running ES LDAP setup"
    Copy-Item "C:\Program Files (x86)\Micro Focus\Enterprise Developer\etc\cas\dfhdrdat" -Destination $PSScriptRoot
    $ESLdapCmd = "C:\Program Files (x86)\Micro Focus\Enterprise Developer\bin\es-ldap-setup.cmd"
    (Get-Content $ESLdapCmd) -Replace 'pause', ' ' | Set-Content $ESLdapCmd
    & $ESLdapCmd /ad - - "$PartitionDN" localhost:389

    # 4 - ESM config via ESCWA REST API
    Write-Step "4/4 - Configuring ESM module"

    $LDAPConfig = "[LDAP]`nBASE=$PartitionDN`nuser class=microfocus-MFDS-User`nuser container=CN=Enterprise Server Users`ngroup container=CN=Enterprise Server User Groups`nresource container=CN=Enterprise Server Resources`n`n[Operation]`nset login count=yes`nsignon attempts=3`n`n[Verify]`nMode=MF-hash`n`n[Trace]`nModify=y`nRule=y`nGroups=y`nSearch=y`nBind=n`nTrace1=verify:*:debug`nTrace2=auth:*:*:**:debug"

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

    $MFReaderDN = "CN=Administrator,CN=Users,$DomainDN"

    $ESMBody = @{
        Name           = "ADESM"
        Description    = "AD ESM"
        Module         = "mldap_esm"
        ConnectionPath = "localhost:389"
        AuthorizedID   = $MFReaderDN
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
        mfESMID             = $MFReaderDN
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

    # DONE
    Write-Host "`nAD + ESM configuration complete." -ForegroundColor Green
}