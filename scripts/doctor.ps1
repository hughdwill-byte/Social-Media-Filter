# FeedFilter stage-1 doctor. Read-only: reports on this Windows PC and writes
# report files under the runtime directory. It does not change network, firewall,
# certificate trust, startup or execution-policy settings. No admin needed.
param(
    [string]$RuntimeDir,
    [switch]$NoOpen
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path (Join-Path $PSScriptRoot 'lib') 'FeedFilter.psm1') -Force

$version = Get-FFVersion
$repoRoot = Split-Path -Parent $PSScriptRoot
$runtime = Get-FFRuntimeDir $RuntimeDir
$reports = Join-Path $runtime 'reports'
$configPath = Join-Path $runtime 'config.local.json'
$confDir = Join-Path $runtime 'mitmproxy'
$stamp = (Get-Date).ToString('yyyyMMdd-HHmmss')

$checks = New-Object System.Collections.ArrayList
function Add-Check([string]$Id, [string]$Status, [string]$Value, [string]$Err) {
    [void]$checks.Add([pscustomobject]@{ Id = $Id; Status = $Status; Value = $Value; Error = $Err })
}
# Runs one check; an exception becomes a FAIL row instead of stopping the doctor.
function Invoke-Check([string]$Id, [scriptblock]$Body) {
    try {
        $r = & $Body
        Add-Check $Id $r[0] $r[1] $r[2]
    } catch {
        Add-Check $Id 'FAIL' '' $_.Exception.Message
    }
}

Write-Host "FeedFilter doctor $version (read-only diagnostic)"
Write-Host 'Collecting information; this usually takes under a minute...'

$onWindows = [Environment]::OSVersion.Platform -eq 'Win32NT'
Invoke-Check 'PLATFORM' { if ($onWindows) { @('PASS', 'Windows') } else { @('FAIL', [string][Environment]::OSVersion.Platform, 'Not Windows; Windows checks will fail') } }

Invoke-Check 'OS_VERSION' {
    $os = Get-CimInstance Win32_OperatingSystem
    $cv = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    $disp = $cv.DisplayVersion; if (-not $disp) { $disp = $cv.ReleaseId }
    @('PASS', ("{0} {1} build {2}.{3}" -f $os.Caption, $disp, $os.BuildNumber, $cv.UBR))
}
Invoke-Check 'OS_ARCH' {
    $a = $env:PROCESSOR_ARCHITECTURE
    if ($env:PROCESSOR_ARCHITEW6432) { $a = "$env:PROCESSOR_ARCHITEW6432 (32-bit shell)" }
    @('PASS', $a)
}
Invoke-Check 'POWERSHELL' { @('PASS', ("{0} {1}.{2}" -f $PSVersionTable.PSEdition, $PSVersionTable.PSVersion.Major, $PSVersionTable.PSVersion.Minor)) }
Invoke-Check 'ADMIN' {
    $p = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { @('INFO', 'elevated (not needed for this step)') } else { @('PASS', 'not elevated (expected)') }
}
Invoke-Check 'EXEC_POLICY' {
    $gpo = @(Get-ExecutionPolicy -List | Where-Object { $_.Scope -in 'MachinePolicy', 'UserPolicy' -and "$($_.ExecutionPolicy)" -notin 'Undefined', 'Unrestricted', 'Bypass' })
    $txt = (Get-ExecutionPolicy -List | ForEach-Object { "$($_.Scope)=$($_.ExecutionPolicy)" }) -join ' '
    if ($gpo.Count) { @('WARN', $txt, 'Group policy overrides -ExecutionPolicy Bypass; if launchers fail, unblock the ZIP before extracting (see NEXT_STEPS)') } else { @('PASS', $txt) }
}
Invoke-Check 'CURL' {
    $c = Get-Command curl.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $c) { return @('WARN', 'not found') }
    $r = Invoke-FFBounded $c.Source '--version' 15
    @('PASS', (($r.StdOut -split "`n")[0] -replace '^(curl \S+).*', '$1'))
}
Invoke-Check 'WINGET' {
    $c = Get-Command winget.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $c) { return @('INFO', 'not found (not required)') }
    $r = Invoke-FFBounded $c.Source '--version' 20
    @('INFO', $r.StdOut.Trim())
}
Invoke-Check 'PYTHON' {
    $c = Get-Command python.exe, py.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $c) { return @('INFO', 'not found (not required)') }
    if ($c.Source -like '*\WindowsApps\*') { return @('INFO', 'Microsoft Store alias only (not required)') }
    $r = Invoke-FFBounded $c.Source '--version' 15
    @('INFO', (("$($r.StdOut) $($r.StdErr)").Trim() + ' (not required)'))
}

# mitmweb: presence, version and option compatibility.
$mitm = $null; $mitmVersion = $null; $helpMissing = $null; $optMissing = $null
Invoke-Check 'MITMWEB_FOUND' {
    $script:mitm = Find-FFMitmweb
    if (-not $script:mitm) { return @('FAIL', 'not found', 'Install the official Windows mitmproxy package, open a NEW window, rerun doctor') }
    if ($script:mitm.Where -eq 'PATH') { @('PASS', 'on PATH') } else { @('WARN', 'installed but not on this window''s PATH', 'Open a new window or sign out/in; launchers will use the install path') }
}
if ($mitm) {
    Invoke-Check 'MITMWEB_VERSION' {
        $r = Invoke-FFBounded $script:mitm.Path '--version' 90
        if ($r.TimedOut) { return @('FAIL', '', 'mitmweb --version timed out after 90s') }
        if ($r.Error) { return @('FAIL', '', $r.Error) }
        $script:mitmVersion = Get-FFMitmVersion ($r.StdOut + "`n" + $r.StdErr)
        if ($script:mitmVersion) { @('PASS', $script:mitmVersion) } else { @('FAIL', '', ("exit $($r.ExitCode): " + ($r.StdErr + ' ' + $r.StdOut).Trim())) }
    }
    Invoke-Check 'MITMWEB_HELP' {
        # mitmweb --help may exit non-zero; judge by content.
        $r = Invoke-FFBounded $script:mitm.Path '--help' 90
        if ($r.TimedOut -or $r.Error) { return @('FAIL', '', "--help failed: $($r.Error) timedOut=$($r.TimedOut)") }
        $script:helpMissing = Get-FFMissingTokens ($r.StdOut + "`n" + $r.StdErr) (Get-FFMitmRequired).Flags
        if ($script:helpMissing.Count) { @('FAIL', 'missing: ' + ($script:helpMissing -join ' ')) } else { @('PASS', 'required flags present') }
    }
    Invoke-Check 'MITMWEB_OPTIONS' {
        $r = Invoke-FFBounded $script:mitm.Path '--options' 90
        if ($r.TimedOut -or $r.Error) { return @('WARN', '', "--options failed: $($r.Error) timedOut=$($r.TimedOut)") }
        $script:optMissing = Get-FFMissingTokens ($r.StdOut + "`n" + $r.StdErr) (Get-FFMitmRequired).Options -Options
        if ($script:optMissing.Count) { @('WARN', 'missing: ' + ($script:optMissing -join ' ')) } else { @('PASS', 'required options present') }
    }
}

# Network.
$adapters = @()
Invoke-Check 'NET_ADAPTERS' {
    $script:adapters = @(Get-FFAdapterInventory)
    $cand = @($script:adapters | Where-Object { Test-FFCandidate $_ })
    $status = 'PASS'; if (-not $cand.Count) { $status = 'FAIL' } elseif ($cand.Count -gt 1) { $status = 'WARN' }
    @($status, "$($script:adapters.Count) adapters, $($cand.Count) home-LAN candidates")
}
$config = $null
Invoke-Check 'CONFIG' {
    if (-not (Test-Path -LiteralPath $configPath)) { return @('INFO', 'config.local.json not created yet') }
    $script:config = Read-FFConfig $configPath
    @('PASS', "present (schema $($script:config.schema_version), written by $($script:config.written_by_version))")
}
$lan = Get-FFLanSelectionStatus $config $adapters
if ($lan.Adapter) { $lan.Adapter.Selected = $true }

Invoke-Check 'NET_PROFILE_SELECTED' {
    if (-not $lan.Adapter) { return @('NOT_RUN', 'no adapter selected yet') }
    $cat = $lan.Adapter.NetworkCategory
    if ($cat -eq 'Private') { @('PASS', 'Private') } else { @('WARN', $cat, 'Set this trusted home network to Private (guide section 4) before stage 2') }
}
Invoke-Check 'FIREWALL' {
    $p = Get-NetFirewallProfile -Profile Private, Public -ErrorAction Stop
    @('INFO', (($p | ForEach-Object { "$($_.Name)=$(if ($_.Enabled) { 'on' } else { 'off' })" }) -join ' '))
}
$ports = @{}
foreach ($port in 8080, 8081) {
    Invoke-Check "PORT_$port" {
        $l = @(Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue)
        if (-not $l.Count) { $script:ports[$port] = 'FREE'; return @('PASS', 'free') }
        $names = ($l | ForEach-Object { (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName } | Sort-Object -Unique) -join ','
        $script:ports[$port] = 'IN_USE'
        @('WARN', "in use by: $names")
    }
}

# Resources needed later.
Invoke-Check 'CPU' { $c = @(Get-CimInstance Win32_Processor); @('INFO', ("{0}; {1} logical processors" -f $c[0].Name.Trim(), ($c | Measure-Object NumberOfLogicalProcessors -Sum).Sum)) }
Invoke-Check 'RAM' { $m = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory; @('INFO', ("{0:N1} GB" -f ($m / 1GB))) }
Invoke-Check 'DISK_FREE' {
    $d = New-Object IO.DriveInfo ([IO.Path]::GetPathRoot($runtime))
    $gb = $d.AvailableFreeSpace / 1GB
    $s = 'PASS'; if ($gb -lt 5) { $s = 'WARN' }
    @($s, ("{0:N1} GB free on runtime drive" -f $gb))
}
Invoke-Check 'GPU' { @('INFO', ((Get-CimInstance Win32_VideoController | ForEach-Object { $_.Name }) -join '; ')) }
Invoke-Check 'BATTERY' {
    if (@(Get-CimInstance Win32_Battery).Count) { @('INFO', 'battery present (laptop): keep plugged in and awake when filtering') } else { @('INFO', 'no battery') }
}
Invoke-Check 'RUNTIME_DIR' { @('INFO', "existed before this run=$(Test-Path -LiteralPath $runtime); mitmproxy confdir exists=$(Test-Path -LiteralPath $confDir)") }
Invoke-Check 'CA_PRESENT' {
    # Existence only; certificate/key contents are never read.
    @('INFO', "mitmproxy CA cert file exists=$(Test-Path -LiteralPath (Join-Path $confDir 'mitmproxy-ca-cert.pem'))")
}

# Summary.
$tools = 'NOT_READY'; $toolNote = 'mitmweb not found'
if ($mitm) {
    $toolNote = "mitmweb $mitmVersion"
    if ($mitmVersion -and $null -ne $helpMissing -and $helpMissing.Count -eq 0) {
        if ($mitm.Where -eq 'PATH') { $tools = 'READY' } else { $tools = 'READY_OFF_PATH' }
    } else { $toolNote = 'mitmweb found but version/help check failed' }
}
$portStatus = 'FREE'; if ($ports.Values -contains 'IN_USE') { $portStatus = 'IN_USE' } elseif ($ports.Count -lt 2) { $portStatus = 'UNKNOWN' }
$summary = @(
    [pscustomobject]@{ Id = 'TOOLS_MITMWEB'; Status = $tools; Note = $toolNote },
    [pscustomobject]@{ Id = 'LAN_SELECTION'; Status = $lan.Status; Note = $lan.Note },
    [pscustomobject]@{ Id = 'PORTS_8080_8081'; Status = $portStatus; Note = '' },
    [pscustomobject]@{ Id = 'STAGE1_GATE'; Status = 'WAITING_FOR_USER_TEST'; Note = 'Agent records PASS/FAIL after reviewing this file' }
)

$report = [pscustomobject]@{
    Tool = 'doctor'; Version = $version; GeneratedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    RevisionHint = Get-FFRevisionHint (Split-Path -Leaf $repoRoot)
    Summary = $summary; Checks = @($checks); Adapters = @($adapters)
}

# Labels for private values. Order matters only for readability; matching is exact.
$labels = @{}
foreach ($a in $adapters) {
    if ($a.IPv4) { $labels[$a.IPv4] = $a.Label }
    if ($a.Gateway -and $a.Gateway -ne '0.0.0.0') { $labels[$a.Gateway] = 'GATEWAY' }
    if ($a.MacAddress) { $labels[$a.MacAddress] = '[MAC]' }
}
if ($config -and $config.phone_lan -and $config.phone_lan.ipv4) { $labels[$config.phone_lan.ipv4] = 'PHONE_LAN' }
if ($config -and $config.pc_lan -and $config.pc_lan.ipv4 -and -not $labels[$config.pc_lan.ipv4]) { $labels[$config.pc_lan.ipv4] = 'PC_LAN_SAVED' }
foreach ($p in @($runtime, $env:LOCALAPPDATA, $env:USERPROFILE, $repoRoot)) { if ($p) { $labels[$p] = '[PATH]' } }
$secrets = @($env:USERNAME, $env:COMPUTERNAME, $env:USERDOMAIN, $env:USERDNSDOMAIN) + @($adapters | ForEach-Object { $_.Alias }) | Where-Object { $_ -and $_.Length -ge 3 -and $_ -notin 'Wi-Fi', 'Ethernet', 'WORKGROUP' }

$share = New-FFShareBack -Report $report -Labels $labels -Secrets $secrets
$private = @($labels.Keys) + @($secrets)
$leaks = Find-FFLeaks $share $private
if ($leaks.Count) {
    # Should not happen; refuse to write a share file that contains private values.
    $share = "# FeedFilter SHARE_BACK`r`n`r`nThe exporter detected $($leaks.Count) private value(s) in its own output and withheld the summary. Return only this line to the agent: EXPORTER_LEAK_GUARD_TRIGGERED version $version`r`n"
}

New-Item -ItemType Directory -Path $reports -Force | Out-Null
$privatePath = Join-Path $reports "doctor-$stamp.private.json"
$sharePath = Join-Path $reports 'SHARE_BACK.md'
Write-FFText $privatePath ($report | ConvertTo-Json -Depth 6)
Write-FFText $sharePath $share

Write-Host ''
Write-Host "FeedFilter doctor $version"
foreach ($s in $summary) { Write-Host ("  {0,-16} {1,-22} {2}" -f $s.Id, $s.Status, $s.Note) }
Write-Host ''
foreach ($c in $checks) { if ($c.Status -in 'FAIL', 'WARN') { Write-Host ("  {0,-5} {1}: {2} {3}" -f $c.Status, $c.Id, $c.Value, $c.Error) } }
Write-Host ''
Write-Host "Private report (keep on this PC): $privatePath"
Write-Host "Share file (review, then paste):  $sharePath"
if (-not $NoOpen -and $onWindows) { Start-Process notepad.exe -ArgumentList "`"$sharePath`"" }
exit 0
