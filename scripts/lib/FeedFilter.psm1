# FeedFilter shared helpers. Windows PowerShell 5.1 compatible; keep this file ASCII-only.
# Pure functions (no system access) come first and are covered by tests\run-tests.ps1.
# Gathering functions at the bottom only read system state; nothing here changes
# network, firewall, certificate trust or startup settings.

$script:RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

function Get-FFVersion {
    (Get-Content -LiteralPath (Join-Path $script:RepoRoot 'VERSION') -Raw).Trim()
}

function Get-FFRuntimeDir {
    param([string]$Override)
    if ($Override) { return $Override }
    if (-not $env:LOCALAPPDATA) { throw 'LOCALAPPDATA is not set; pass -RuntimeDir.' }
    Join-Path $env:LOCALAPPDATA 'FeedFilter'
}

# GitHub "download commit as ZIP" folders end in -<sha>; branch ZIPs do not.
function Get-FFRevisionHint {
    param([string]$FolderName)
    if ($FolderName -match '-([0-9a-f]{7,40})$') { return $Matches[1] }
    return $null
}

function Test-FFIPv4 {
    param([string]$Ip)
    $o = '(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)'
    return [bool]($Ip -match "^($o\.){3}$o$")
}

function ConvertTo-FFIPv4Number {
    param([string]$Ip)
    $p = $Ip.Split('.')
    return ([int64]$p[0] * 16777216) + ([int64]$p[1] * 65536) + ([int64]$p[2] * 256) + [int64]$p[3]
}

function Get-FFIPv4Class {
    param([string]$Ip)
    if (-not (Test-FFIPv4 $Ip)) { return 'INVALID' }
    $p = $Ip.Split('.') | ForEach-Object { [int]$_ }
    if ($p[0] -eq 10) { return 'PRIVATE_10' }
    if ($p[0] -eq 172 -and $p[1] -ge 16 -and $p[1] -le 31) { return 'PRIVATE_172' }
    if ($p[0] -eq 192 -and $p[1] -eq 168) { return 'PRIVATE_192' }
    if ($p[0] -eq 169 -and $p[1] -eq 254) { return 'LINK_LOCAL' }
    if ($p[0] -eq 100 -and $p[1] -ge 64 -and $p[1] -le 127) { return 'CGNAT' }
    if ($p[0] -eq 127) { return 'LOOPBACK' }
    if ($p[0] -eq 0 -or $p[0] -ge 224) { return 'RESERVED' }
    return 'PUBLIC'
}

function Test-FFSameSubnet {
    param([string]$A, [string]$B, [int]$PrefixLength)
    if (-not (Test-FFIPv4 $A) -or -not (Test-FFIPv4 $B)) { return $false }
    if ($PrefixLength -lt 0 -or $PrefixLength -gt 32) { return $false }
    $block = [int64][math]::Pow(2, 32 - $PrefixLength)
    return ([math]::Floor((ConvertTo-FFIPv4Number $A) / $block)) -eq ([math]::Floor((ConvertTo-FFIPv4Number $B) / $block))
}

# ponytail: name/description pattern list; extend when a user's adapter is misclassified.
$script:VirtualPatterns = @(
    @{ Reason = 'WSL_OR_HYPERV'; Pattern = 'WSL|Hyper-V|vEthernet|Default Switch' },
    @{ Reason = 'VM';            Pattern = 'VirtualBox|VMware|Parallels|QEMU|virtio' },
    @{ Reason = 'VPN';           Pattern = 'TAP-|\bTAP\b|Wintun|WireGuard|Tailscale|ZeroTier|OpenVPN|AnyConnect|GlobalProtect|PANGP|Fortinet|FortiClient|NordLynx|Mullvad|Proton|Hamachi|Radmin|WARP|Cloudflare|SonicWall|Juniper|Pulse Secure|VPN' },
    @{ Reason = 'CONTAINER';     Pattern = 'Docker' },
    @{ Reason = 'BLUETOOTH';     Pattern = 'Bluetooth' },
    @{ Reason = 'LOOPBACK';      Pattern = 'Loopback' },
    @{ Reason = 'CAPTURE';       Pattern = 'Npcap|WinPcap' },
    @{ Reason = 'WIFI_DIRECT';   Pattern = 'Wi-Fi Direct|Virtual Adapter' }
)

function Get-FFAdapterClass {
    param([string]$Name, [string]$Description, [object]$HardwareInterface, [object]$Virtual, [string]$MediaType)
    $text = "$Name $Description"
    $reason = $null
    foreach ($v in $script:VirtualPatterns) {
        if ($text -match $v.Pattern) { $reason = $v.Reason; break }
    }
    if (-not $reason -and ($Virtual -eq $true -or $HardwareInterface -eq $false)) { $reason = 'OTHER_VIRTUAL' }
    $kind = 'OTHER'
    if ($MediaType -match '802\.11' -or $text -match 'Wi-?Fi|WLAN|Wireless') { $kind = 'WIFI' }
    elseif ($MediaType -match '802\.3' -or $text -match 'Ethernet|GbE|LAN') { $kind = 'ETHERNET' }
    return [pscustomobject]@{ Kind = $kind; IsVirtual = [bool]$reason; VirtualReason = $reason }
}

# A usable home-LAN candidate: not virtual, up, with a private non-link-local IPv4.
function Test-FFCandidate {
    param($Adapter)
    return (-not $Adapter.IsVirtual) -and ($Adapter.Status -eq 'Up') -and ((Get-FFIPv4Class $Adapter.IPv4) -like 'PRIVATE_*')
}

# Orders adapters and gives each a stable share-back label (PC_LAN_n / VIRTUAL_n / OTHER_n).
function Set-FFAdapterLabels {
    param([object[]]$Adapters)
    $sorted = @($Adapters | Sort-Object @{ Expression = { -not (Test-FFCandidate $_) } }, @{ Expression = { -not $_.HasDefaultRoute } }, @{ Expression = { $_.RouteMetric } }, @{ Expression = { $_.IfIndex } })
    $n = @{ PC_LAN = 0; VIRTUAL = 0; OTHER = 0 }
    foreach ($a in $sorted) {
        if (Test-FFCandidate $a) { $k = 'PC_LAN' } elseif ($a.IsVirtual) { $k = 'VIRTUAL' } else { $k = 'OTHER' }
        $n[$k]++
        $a | Add-Member -NotePropertyName Label -NotePropertyValue ("{0}_{1}" -f $k, $n[$k]) -Force
    }
    return $sorted
}

function Get-FFLanSelectionStatus {
    param($Config, [object[]]$Adapters)
    $candidates = @($Adapters | Where-Object { Test-FFCandidate $_ })
    if (-not $Config -or -not $Config.pc_lan -or -not $Config.pc_lan.ipv4) {
        if ($candidates.Count -gt 1) { return [pscustomobject]@{ Status = 'NOT_SELECTED'; Note = "$($candidates.Count) candidate adapters; choose locally with scripts\configure.cmd"; Adapter = $null } }
        return [pscustomobject]@{ Status = 'NOT_SELECTED'; Note = 'Run scripts\configure.cmd'; Adapter = $null }
    }
    $sel = @($Adapters | Where-Object { $_.Alias -eq $Config.pc_lan.interface_alias -and $_.IPv4 -eq $Config.pc_lan.ipv4 }) | Select-Object -First 1
    if (-not $sel) { return [pscustomobject]@{ Status = 'STALE'; Note = 'Saved PC_LAN adapter/address is not present now; rerun scripts\configure.cmd'; Adapter = $null } }
    if (-not $Config.phone_lan -or -not $Config.phone_lan.ipv4) { return [pscustomobject]@{ Status = 'PHONE_MISSING'; Note = 'PHONE_LAN address not entered'; Adapter = $sel } }
    if (-not (Test-FFSameSubnet $sel.IPv4 $Config.phone_lan.ipv4 $sel.PrefixLength)) { return [pscustomobject]@{ Status = 'SUBNET_MISMATCH'; Note = 'PHONE_LAN is outside the PC_LAN subnet'; Adapter = $sel } }
    if ($sel.IsVirtual) { return [pscustomobject]@{ Status = 'SELECTED_VIRTUAL'; Note = "Selected adapter looks virtual ($($sel.VirtualReason)); confirm it is really the home LAN"; Adapter = $sel } }
    if ($sel.Status -ne 'Up') { return [pscustomobject]@{ Status = 'SELECTED_DOWN'; Note = 'Selected adapter is not Up'; Adapter = $sel } }
    return [pscustomobject]@{ Status = 'SELECTED'; Note = 'PC_LAN and PHONE_LAN on the same subnet'; Adapter = $sel }
}

$script:RequiredMitmFlags = @('--listen-host', '--listen-port', '--set', '--allow-hosts')
$script:RequiredMitmOptions = @('web_host', 'web_port', 'confdir', 'listen_host', 'listen_port', 'allow_hosts')

# Help flags appear after whitespace/comma; --options entries are "name: value" at line start.
function Get-FFMissingTokens {
    param([string]$Text, [string[]]$Tokens, [switch]$Options)
    $pre = '(^|[\s,])'; $post = '\b'
    if ($Options) { $pre = '^'; $post = ':' }
    return ,@($Tokens | Where-Object { $Text -notmatch ('(?m)' + $pre + [regex]::Escape($_) + $post) })
}

function Get-FFMitmRequired { return [pscustomobject]@{ Flags = $script:RequiredMitmFlags; Options = $script:RequiredMitmOptions } }

function Get-FFMitmVersion {
    param([string]$Text)
    if ($Text -match '(?im)^\s*Mitmproxy:\s*([0-9][0-9A-Za-z.\-+]*)') { return $Matches[1] }
    return $null
}

# Replaces known private values with labels, then scrubs generic identifiers.
# $Labels: exact value -> label (addresses, paths). $Secrets: values that must never appear.
function ConvertTo-FFRedacted {
    param([string]$Text, [hashtable]$Labels = @{}, [string[]]$Secrets = @(), [int]$Max = 240)
    if (-not $Text) { return '' }
    $t = $Text -replace '[\r\n\t]+', ' '
    foreach ($k in ($Labels.Keys | Sort-Object Length -Descending)) {
        if ($k) { $t = [regex]::Replace($t, '(?<![\w.])' + [regex]::Escape($k) + '(?!\w)', $Labels[$k].Replace('$', '$$'), 'IgnoreCase') }
    }
    foreach ($s in $Secrets) {
        if ($s -and $s.Length -ge 3) { $t = [regex]::Replace($t, [regex]::Escape($s), '[REDACTED]', 'IgnoreCase') }
    }
    $t = [regex]::Replace($t, '(?i)[a-z]:\\Users\\[^\\\s"'']+', '%USERPROFILE%')
    $t = [regex]::Replace($t, '\\\\[^\\\s]+', '\\[HOST]')
    $t = [regex]::Replace($t, '[\w.+-]+@[\w-]+\.[\w.-]+', '[EMAIL]')
    $t = [regex]::Replace($t, '\{?[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}\}?', '[GUID]')
    $t = [regex]::Replace($t, '\b([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\b', '[MAC]')
    $t = [regex]::Replace($t, '(?<![\w.])\d{1,3}(\.\d{1,3}){3}(?![\w.]*\d)', '[IPv4]')
    $t = [regex]::Replace($t, '(?i)(?<![\w:])(?:[0-9a-f]{0,4}:){2,7}[0-9a-f]{0,4}(%\w+)?(?![\w:])', '[IPv6]')
    if ($t.Length -gt $Max) { $t = $t.Substring(0, $Max) + '...' }
    return $t
}

function ConvertTo-FFCell {
    param([string]$Text)
    if (-not $Text) { return '' }
    return ($Text -replace '\|', '/' -replace '[\r\n]+', ' ').Trim()
}

# Builds SHARE_BACK.md from an allowlist of report fields. Nothing else from the
# private report is copied. Errors are redacted; values are redacted against known
# private strings as a second line of defence.
function New-FFShareBack {
    param($Report, [hashtable]$Labels = @{}, [string[]]$Secrets = @())
    $r = { param($s) ConvertTo-FFCell (ConvertTo-FFRedacted -Text ([string]$s) -Labels $Labels -Secrets $Secrets) }
    $v = { param($s) ConvertTo-FFCell (ConvertTo-FFRedacted -Text ([string]$s) -Labels $Labels -Secrets $Secrets -Max 160) }
    $L = New-Object System.Collections.Generic.List[string]
    $L.Add('# FeedFilter SHARE_BACK')
    $L.Add('')
    $L.Add('Review this file before pasting it to the coding agent. It is built from an allowlist and should contain no addresses, account/PC names, network names or file paths. If you see one, delete it and tell the agent.')
    $L.Add('')
    $L.Add('```text')
    $L.Add("FeedFilter version: $(& $v $Report.Version)")
    $hint = $Report.RevisionHint; if (-not $hint) { $hint = 'unknown (branch ZIP or renamed folder; state the commit you downloaded)' }
    $L.Add("Revision folder hint: $(& $v $hint)")
    $L.Add("Tool: $(& $v $Report.Tool)")
    $L.Add("Generated UTC: $(& $v $Report.GeneratedUtc)")
    $L.Add('Evidence environment: USER_WINDOWS (local doctor output, user-reported)')
    $L.Add('Workflow state: WAITING_FOR_USER_TEST until the agent records this result')
    $L.Add('```')
    $L.Add('')
    $L.Add('## Summary')
    $L.Add('')
    $L.Add('| Item | Status | Note |')
    $L.Add('| --- | --- | --- |')
    foreach ($s in @($Report.Summary)) { $L.Add("| $(& $v $s.Id) | $(& $v $s.Status) | $(& $r $s.Note) |") }
    $L.Add('')
    $L.Add('## Checks')
    $L.Add('')
    $L.Add('| Check | Status | Value | Redacted error |')
    $L.Add('| --- | --- | --- | --- |')
    foreach ($c in @($Report.Checks)) { $L.Add("| $(& $v $c.Id) | $(& $v $c.Status) | $(& $v $c.Value) | $(& $r $c.Error) |") }
    $L.Add('')
    $L.Add('## Network adapters (labels only)')
    $L.Add('')
    $L.Add('| Label | Kind | Virtual | Up | IPv4 range/prefix | Default route | Windows profile | IPv6 | Selected |')
    $L.Add('| --- | --- | --- | --- | --- | --- | --- | --- | --- |')
    foreach ($a in @($Report.Adapters)) {
        $virt = 'no'; if ($a.IsVirtual) { $virt = "yes ($($a.VirtualReason))" }
        $range = 'none'; if ($a.IPv4) { $range = "$(Get-FFIPv4Class $a.IPv4) /$($a.PrefixLength)" }
        $L.Add("| $(& $v $a.Label) | $(& $v $a.Kind) | $(& $v $virt) | $(& $v ($a.Status -eq 'Up')) | $(& $v $range) | $(& $v $a.HasDefaultRoute) | $(& $v $a.NetworkCategory) | $(& $v $a.HasIPv6) | $(& $v $a.Selected) |")
    }
    if (-not @($Report.Adapters).Count) { $L.Add('| (none reported) | | | | | | | | |') }
    $L.Add('')
    $L.Add('Optional note from you (phone/iOS/app versions if you have them, or what went wrong):')
    $L.Add('')
    return ($L -join "`r`n") + "`r`n"
}

# Returns the private strings that leaked into $Text (exact, case-insensitive).
function Find-FFLeaks {
    param([string]$Text, [string[]]$Private)
    return ,@($Private | Where-Object { $_ -and $_.Length -ge 3 -and $Text.IndexOf($_, [StringComparison]::OrdinalIgnoreCase) -ge 0 })
}

function Read-FFConfig {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

function Set-FFProp {
    param($Object, [string]$Name, $Value)
    $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value -Force
}

# Merges the LAN selection into the existing config (unknown keys preserved),
# keeps one .bak of the previous file, and writes via a temp file.
function Save-FFConfig {
    param([string]$Path, $Existing, $PcLan, [string]$PhoneIPv4, [string]$Version)
    if ($PhoneIPv4 -and -not (Test-FFIPv4 $PhoneIPv4)) { throw "Not a valid IPv4 address: $PhoneIPv4" }
    $c = $Existing; if (-not $c) { $c = [pscustomobject]@{} }
    Set-FFProp $c 'schema_version' 1
    Set-FFProp $c 'written_by_version' $Version
    Set-FFProp $c 'updated_utc' ((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))
    Set-FFProp $c 'pc_lan' $PcLan
    $phone = $null; if ($PhoneIPv4) { $phone = [pscustomobject]@{ ipv4 = $PhoneIPv4 } }
    Set-FFProp $c 'phone_lan' $phone
    if (-not ($c.PSObject.Properties.Name -contains 'proxy')) {
        Set-FFProp $c 'proxy' ([pscustomobject]@{ listen_port = 8080; web_host = '127.0.0.1'; web_port = 8081 })
    }
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    if (Test-Path -LiteralPath $Path) { Copy-Item -LiteralPath $Path -Destination "$Path.bak" -Force }
    $tmp = "$Path.tmp"
    [IO.File]::WriteAllText($tmp, ($c | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding($false)))
    Move-Item -LiteralPath $tmp -Destination $Path -Force
    return $c
}

function Write-FFText {
    param([string]$Path, [string]$Text)
    [IO.File]::WriteAllText($Path, $Text, (New-Object Text.UTF8Encoding($false)))
}

# ---- Read-only gathering (Windows only) ----

# Runs an executable with a hard timeout; never throws.
function Invoke-FFBounded {
    param([string]$File, [string]$Arguments, [int]$TimeoutSec = 60)
    $res = [pscustomobject]@{ ExitCode = $null; StdOut = ''; StdErr = ''; TimedOut = $false; Error = $null }
    try {
        $psi = New-Object Diagnostics.ProcessStartInfo
        $psi.FileName = $File
        $psi.Arguments = $Arguments
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.CreateNoWindow = $true
        $p = [Diagnostics.Process]::Start($psi)
        $out = $p.StandardOutput.ReadToEndAsync()
        $err = $p.StandardError.ReadToEndAsync()
        if (-not $p.WaitForExit($TimeoutSec * 1000)) {
            $res.TimedOut = $true
            try { $p.Kill() } catch { }
            return $res
        }
        $res.ExitCode = $p.ExitCode
        $res.StdOut = $out.Result
        $res.StdErr = $err.Result
    } catch { $res.Error = $_.Exception.Message }
    return $res
}

# Locates mitmweb without relying on the current session PATH being fresh.
function Find-FFMitmweb {
    $cmd = Get-Command 'mitmweb.exe', 'mitmweb' -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd) { return [pscustomobject]@{ Path = $cmd.Source; Where = 'PATH' } }
    $dirs = @()
    if ($env:ProgramFiles) { $dirs += Join-Path $env:ProgramFiles 'mitmproxy\bin' }
    if (${env:ProgramFiles(x86)}) { $dirs += Join-Path ${env:ProgramFiles(x86)} 'mitmproxy\bin' }
    if ($env:LOCALAPPDATA) { $dirs += Join-Path $env:LOCALAPPDATA 'Programs\mitmproxy\bin' }
    foreach ($d in $dirs) {
        $f = Join-Path $d 'mitmweb.exe'
        if (Test-Path -LiteralPath $f) { return [pscustomobject]@{ Path = $f; Where = 'INSTALL_DIR_NOT_ON_PATH' } }
    }
    return $null
}

function Get-FFAdapterInventory {
    $ip4 = @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue)
    $ip6 = @(Get-NetIPAddress -AddressFamily IPv6 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike 'fe80*' })
    $routes = @(Get-NetRoute -DestinationPrefix '0.0.0.0/0' -AddressFamily IPv4 -ErrorAction SilentlyContinue)
    $profiles = @(Get-NetConnectionProfile -ErrorAction SilentlyContinue)
    $list = @()
    foreach ($n in @(Get-NetAdapter -ErrorAction Stop)) {
        $cls = Get-FFAdapterClass -Name $n.Name -Description $n.InterfaceDescription -HardwareInterface $n.HardwareInterface -Virtual $n.Virtual -MediaType ("$($n.PhysicalMediaType) $($n.MediaType)")
        $addr = $ip4 | Where-Object { $_.InterfaceIndex -eq $n.ifIndex -and $_.IPAddress -notlike '169.254.*' } | Select-Object -First 1
        if (-not $addr) { $addr = $ip4 | Where-Object { $_.InterfaceIndex -eq $n.ifIndex } | Select-Object -First 1 }
        $route = $routes | Where-Object { $_.InterfaceIndex -eq $n.ifIndex } | Sort-Object RouteMetric | Select-Object -First 1
        $prof = $profiles | Where-Object { $_.InterfaceIndex -eq $n.ifIndex } | Select-Object -First 1
        $ipv4 = $null; $prefix = $null; if ($addr) { $ipv4 = $addr.IPAddress; $prefix = [int]$addr.PrefixLength }
        $gw = $null; $metric = 99999; if ($route) { $gw = $route.NextHop; $metric = [int]$route.RouteMetric }
        $cat = 'none'; if ($prof) { $cat = [string]$prof.NetworkCategory }
        $list += [pscustomobject]@{
            Alias = $n.Name; Description = $n.InterfaceDescription; IfIndex = $n.ifIndex; Status = [string]$n.Status
            Kind = $cls.Kind; IsVirtual = $cls.IsVirtual; VirtualReason = $cls.VirtualReason
            IPv4 = $ipv4; PrefixLength = $prefix; Gateway = $gw; HasDefaultRoute = [bool]$route; RouteMetric = $metric
            NetworkCategory = $cat; HasIPv6 = [bool]($ip6 | Where-Object { $_.InterfaceIndex -eq $n.ifIndex })
            MacAddress = $n.MacAddress; Selected = $false
        }
    }
    return Set-FFAdapterLabels $list
}

Export-ModuleMember -Function *-FF*
