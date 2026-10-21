# Assert-based tests for the stage-1 parser/exporter. Run: pwsh -File tests/run-tests.ps1
# (or powershell.exe on Windows). Exit code = number of failures.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path (Join-Path (Join-Path $root 'scripts') 'lib') 'FeedFilter.psm1') -Force
$fixtures = Join-Path $PSScriptRoot 'fixtures'
$script:fail = 0
function Check([string]$Name, [bool]$Ok) {
    if ($Ok) { Write-Host "ok   $Name" } else { Write-Host "FAIL $Name"; $script:fail++ }
}

# IPv4 parsing/classification
Check 'valid ipv4' (Test-FFIPv4 '192.168.1.50')
Check 'reject 256' (-not (Test-FFIPv4 '192.168.1.256'))
Check 'reject leading zero' (-not (Test-FFIPv4 '192.168.01.5'))
Check 'reject junk' (-not (Test-FFIPv4 '192.168.1.5; rm'))
Check 'class 192' ((Get-FFIPv4Class '192.168.0.9') -eq 'PRIVATE_192')
Check 'class 172' ((Get-FFIPv4Class '172.20.1.1') -eq 'PRIVATE_172')
Check 'class 172 outside' ((Get-FFIPv4Class '172.32.1.1') -eq 'PUBLIC')
Check 'class apipa' ((Get-FFIPv4Class '169.254.3.3') -eq 'LINK_LOCAL')
Check 'class cgnat' ((Get-FFIPv4Class '100.101.1.1') -eq 'CGNAT')
Check 'same /24' (Test-FFSameSubnet '192.168.1.50' '192.168.1.60' 24)
Check 'diff /24' (-not (Test-FFSameSubnet '192.168.1.50' '192.168.2.60' 24))
Check 'same /22' (Test-FFSameSubnet '10.0.0.5' '10.0.3.250' 22)
Check 'diff /22' (-not (Test-FFSameSubnet '10.0.0.5' '10.0.4.1' 22))
Check 'same /32 self' (Test-FFSameSubnet '10.0.0.5' '10.0.0.5' 32)

# Adapter classification
$c = Get-FFAdapterClass -Name 'vEthernet (WSL)' -Description 'Hyper-V Virtual Ethernet Adapter' -HardwareInterface $false -Virtual $false -MediaType '802.3'
Check 'wsl is virtual' ($c.IsVirtual -and $c.VirtualReason -eq 'WSL_OR_HYPERV')
$c = Get-FFAdapterClass -Name 'Wi-Fi' -Description 'Intel(R) Wi-Fi 6 AX201 160MHz' -HardwareInterface $true -Virtual $false -MediaType 'Native 802.11'
Check 'intel wifi physical' ((-not $c.IsVirtual) -and $c.Kind -eq 'WIFI')
$c = Get-FFAdapterClass -Name 'Ethernet' -Description 'Realtek PCIe GbE Family Controller' -HardwareInterface $true -Virtual $false -MediaType '802.3'
Check 'realtek ethernet physical' ((-not $c.IsVirtual) -and $c.Kind -eq 'ETHERNET')
$c = Get-FFAdapterClass -Name 'Tailscale' -Description 'Tailscale Tunnel' -HardwareInterface $false -Virtual $false -MediaType ''
Check 'tailscale vpn' ($c.VirtualReason -eq 'VPN')
$c = Get-FFAdapterClass -Name 'Ethernet 3' -Description 'Unknown NDIS' -HardwareInterface $false -Virtual $false -MediaType '802.3'
Check 'non-hardware is virtual' ($c.VirtualReason -eq 'OTHER_VIRTUAL')

# Labelling and LAN selection
function A($alias, $ip, $prefix, $virt, $route, $status = 'Up') {
    [pscustomobject]@{ Alias = $alias; IPv4 = $ip; PrefixLength = $prefix; IsVirtual = $virt; VirtualReason = $(if ($virt) { 'VPN' }); Status = $status; HasDefaultRoute = $route; RouteMetric = $(if ($route) { 25 } else { 99999 }); IfIndex = 1; Gateway = '192.168.1.1'; Kind = 'WIFI'; NetworkCategory = 'Private'; HasIPv6 = $false; MacAddress = 'AA-BB-CC-DD-EE-FF'; Selected = $false }
}
$ads = @(Set-FFAdapterLabels @((A 'Tailscale' '100.88.1.2' 10 $true $false), (A 'Ethernet' '10.1.1.4' 24 $false $false), (A 'Wi-Fi' '192.168.1.50' 24 $false $true)))
Check 'wifi with route is PC_LAN_1' ($ads[0].Alias -eq 'Wi-Fi' -and $ads[0].Label -eq 'PC_LAN_1')
Check 'second candidate PC_LAN_2' (($ads | Where-Object Alias -eq 'Ethernet').Label -eq 'PC_LAN_2')
Check 'vpn labelled VIRTUAL_1' (($ads | Where-Object Alias -eq 'Tailscale').Label -eq 'VIRTUAL_1')
Check 'no config, multiple -> NOT_SELECTED' ((Get-FFLanSelectionStatus $null $ads).Status -eq 'NOT_SELECTED')
$cfg = [pscustomobject]@{ pc_lan = [pscustomobject]@{ interface_alias = 'Wi-Fi'; ipv4 = '192.168.1.50' }; phone_lan = [pscustomobject]@{ ipv4 = '192.168.1.60' } }
Check 'selected' ((Get-FFLanSelectionStatus $cfg $ads).Status -eq 'SELECTED')
$cfg.phone_lan.ipv4 = '192.168.7.60'
Check 'subnet mismatch' ((Get-FFLanSelectionStatus $cfg $ads).Status -eq 'SUBNET_MISMATCH')
$cfg.pc_lan.ipv4 = '192.168.1.99'
Check 'stale address' ((Get-FFLanSelectionStatus $cfg $ads).Status -eq 'STALE')
$cfg2 = [pscustomobject]@{ pc_lan = [pscustomobject]@{ interface_alias = 'Tailscale'; ipv4 = '100.88.1.2' }; phone_lan = [pscustomobject]@{ ipv4 = '100.88.1.9' } }
Check 'virtual selection flagged' ((Get-FFLanSelectionStatus $cfg2 $ads).Status -eq 'SELECTED_VIRTUAL')

# mitmweb help/options parsing against real mitmweb 12.2.3 output captured in the cloud
$req = Get-FFMitmRequired
$help = Get-Content -Raw (Join-Path $fixtures 'mitmweb-12.2.3-help.txt')
$opts = Get-Content -Raw (Join-Path $fixtures 'mitmweb-12.2.3-options.txt')
Check 'help has required flags' ((Get-FFMissingTokens $help $req.Flags).Count -eq 0)
Check 'options has required options' ((Get-FFMissingTokens $opts $req.Options -Options).Count -eq 0)
$m = Get-FFMissingTokens ($help -replace '--allow-hosts', '--allowhosts') $req.Flags
Check 'missing flag detected' ($m.Count -eq 1 -and $m[0] -eq '--allow-hosts')
Check 'comment mention is not an option' ((Get-FFMissingTokens 'override `web_host` here' @('web_host') -Options).Count -eq 1)
Check 'version parse' ((Get-FFMitmVersion "Mitmproxy: 12.2.3`nPython: 3.13") -eq '12.2.3')
Check 'version parse missing' ($null -eq (Get-FFMitmVersion 'command not found'))

# Revision hint from the extracted ZIP folder name
Check 'commit zip hint' ((Get-FFRevisionHint 'Social-Media-Filter-3f2a9c1d0b8e7f6a5b4c3d2e1f0a9b8c7d6e5f4a') -eq '3f2a9c1d0b8e7f6a5b4c3d2e1f0a9b8c7d6e5f4a')
Check 'branch zip no hint' ($null -eq (Get-FFRevisionHint 'Social-Media-Filter-claude-peaceful-hamilton-fyjcns'))

# Redaction
$labels = @{ '192.168.1.50' = 'PC_LAN_1'; '192.168.1.60' = 'PHONE_LAN'; 'C:\Users\Alex Smith\AppData\Local' = '[PATH]' }
$txt = 'bind 192.168.1.50:8080 failed from 192.168.1.60, other 192.168.1.500 and 10.9.8.7; C:\Users\Alex Smith\AppData\Local\FeedFilter; C:\Users\bob\x; host DESKTOP-AB12 user alexs mac 00:11:22:33:44:55 {12345678-1234-1234-1234-123456789abc} fe80::1c2b:3a4d:5e6f:7a8b%12 a@b.com \\NAS\share'
$red = ConvertTo-FFRedacted -Text $txt -Labels $labels -Secrets @('DESKTOP-AB12', 'alexs') -Max 1000
Check 'pc label' ($red -match 'bind PC_LAN_1:8080')
Check 'phone label' ($red -match 'from PHONE_LAN,')
Check 'no raw ip' ($red -notmatch '\b10\.9\.8\.7\b' -and $red -notmatch '192\.168\.1\.(50|60)\b')
Check 'path label' ($red -match '\[PATH\]\\FeedFilter' -and $red -notmatch 'bob')
Check 'secrets gone' ($red -notmatch 'DESKTOP-AB12' -and $red -notmatch 'alexs')
Check 'mac/guid/ipv6/email/unc gone' ($red -notmatch '00:11:22' -and $red -notmatch '12345678-1234' -and $red -notmatch 'fe80' -and $red -notmatch 'a@b\.com' -and $red -notmatch 'NAS')
Check 'truncation' ((ConvertTo-FFRedacted -Text ('x' * 500) -Max 50).Length -eq 53)
Check 'version untouched' ((ConvertTo-FFRedacted -Text 'Windows 10.0.26100 mitmweb 12.2.3') -eq 'Windows 10.0.26100 mitmweb 12.2.3')

# Share-back exporter: allowlist + leak guard
$report = [pscustomobject]@{
    Tool = 'doctor'; Version = '0.1.0-stage1'; GeneratedUtc = '2026-10-21T05:34:12Z'; RevisionHint = $null
    Summary = @([pscustomobject]@{ Id = 'LAN_SELECTION'; Status = 'SELECTED'; Note = 'ok' })
    Checks = @([pscustomobject]@{ Id = 'PORT_8080'; Status = 'FAIL'; Value = ''; Error = 'Cannot bind 192.168.1.50:8080 as DESKTOP-AB12\alexs in C:\Users\Alex Smith\AppData\Local' })
    Adapters = @($ads)
    SecretField = 'MUST-NOT-APPEAR'
}
$share = New-FFShareBack -Report $report -Labels $labels -Secrets @('DESKTOP-AB12', 'alexs')
$private = @($labels.Keys) + @('DESKTOP-AB12', 'alexs', 'Tailscale', 'AA-BB-CC-DD-EE-FF', '10.1.1.4', '100.88.1.2')
Check 'share has version' ($share -match '0\.1\.0-stage1')
Check 'share has labels' ($share -match 'PC_LAN_1' -and $share -match 'VIRTUAL_1')
Check 'share has USER_WINDOWS provenance' ($share -match 'USER_WINDOWS' -and $share -match 'WAITING_FOR_USER_TEST')
Check 'share omits non-allowlisted field' ($share -notmatch 'MUST-NOT-APPEAR')
$leaks = Find-FFLeaks $share $private
Check "share leaks nothing ($($leaks -join ','))" ($leaks.Count -eq 0)
Check 'share redacted error' ($share -match 'Cannot bind PC_LAN_1:8080')
Check 'leak finder works' ((Find-FFLeaks 'x 192.168.1.50 y' @('192.168.1.50')).Count -eq 1)

# Config save/merge/backup
$tmp = Join-Path ([IO.Path]::GetTempPath()) ("ff test " + [guid]::NewGuid().ToString('N'))
$cfgPath = Join-Path $tmp 'config.local.json'
$pc = [pscustomobject]@{ interface_alias = 'Wi-Fi'; interface_description = 'x'; ipv4 = '192.168.1.50'; prefix_length = 24; gateway_ipv4 = '192.168.1.1' }
Save-FFConfig -Path $cfgPath -Existing $null -PcLan $pc -PhoneIPv4 '192.168.1.60' -Version 'test' | Out-Null
$r1 = Read-FFConfig $cfgPath
Check 'config roundtrip' ($r1.pc_lan.ipv4 -eq '192.168.1.50' -and $r1.phone_lan.ipv4 -eq '192.168.1.60' -and $r1.proxy.listen_port -eq 8080)
Set-FFProp $r1 'future_key' 'keep me'
$r1.proxy.listen_port = 8090
Save-FFConfig -Path $cfgPath -Existing $r1 -PcLan $pc -PhoneIPv4 '' -Version 'test2' | Out-Null
$r2 = Read-FFConfig $cfgPath
Check 'unknown keys preserved' ($r2.future_key -eq 'keep me' -and $r2.proxy.listen_port -eq 8090)
Check 'phone cleared' ($null -eq $r2.phone_lan)
Check 'backup written' ((Read-FFConfig "$cfgPath.bak").phone_lan.ipv4 -eq '192.168.1.60')
$threw = $false; try { Save-FFConfig -Path $cfgPath -Existing $r2 -PcLan $pc -PhoneIPv4 '1.2.3' -Version 't' | Out-Null } catch { $threw = $true }
Check 'invalid phone rejected' $threw
Check 'no temp file left' (-not (Test-Path -LiteralPath "$cfgPath.tmp"))

# Doctor smoke test: must finish and write both files on any platform (missing tools are rows, not crashes).
$rt = Join-Path $tmp 'runtime dir'
$ps = (Get-Process -Id $PID).Path
& $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path (Join-Path $root 'scripts') 'doctor.ps1') -RuntimeDir $rt -NoOpen | Out-Null
Check 'doctor exit 0' ($LASTEXITCODE -eq 0)
$sb = Join-Path (Join-Path $rt 'reports') 'SHARE_BACK.md'
Check 'doctor wrote SHARE_BACK.md' (Test-Path -LiteralPath $sb)
Check 'doctor wrote private report' (@(Get-ChildItem -LiteralPath (Join-Path $rt 'reports') -Filter 'doctor-*.private.json').Count -eq 1)
if (Test-Path -LiteralPath $sb) {
    $txt = Get-Content -LiteralPath $sb -Raw
    $mine = @([Environment]::UserName, [Environment]::MachineName, $tmp) | Where-Object { $_ -and $_.Length -ge 3 }
    Check "doctor share has no user/host/path ($((Find-FFLeaks $txt $mine) -join ','))" ((Find-FFLeaks $txt $mine).Count -eq 0)
    Check 'doctor share has summary' ($txt -match 'TOOLS_MITMWEB' -and $txt -match 'LAN_SELECTION')
}
Remove-Item -LiteralPath $tmp -Recurse -Force

Write-Host ''
Write-Host "$script:fail failure(s)"
exit $script:fail
