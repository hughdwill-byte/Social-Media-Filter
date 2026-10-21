# FeedFilter local LAN configuration. Lets you pick the home LAN adapter and enter
# the iPhone Wi-Fi address; saves %LOCALAPPDATA%\FeedFilter\config.local.json.
# Read-only towards the system: it does not change network, firewall or trust settings.
param(
    [string]$RuntimeDir,
    [switch]$ListOnly,
    [string]$InterfaceAlias,   # non-interactive selection (used by CI); requires -Yes to save
    [string]$PhoneIp,
    [switch]$AllowVirtual,
    [switch]$Yes
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path (Join-Path $PSScriptRoot 'lib') 'FeedFilter.psm1') -Force

$version = Get-FFVersion
$configPath = Join-Path (Get-FFRuntimeDir $RuntimeDir) 'config.local.json'
$interactive = -not $InterfaceAlias

function Ask([string]$Prompt) {
    $a = Read-Host $Prompt
    if ($a -match '^\s*[qQ]\s*$') { Write-Host 'Quit; nothing saved.'; exit 1 }
    return $a.Trim()
}

$adapters = @(Get-FFAdapterInventory)
Write-Host "FeedFilter configure $version"
Write-Host ''
Write-Host 'Network adapters on this PC (shown only on this screen; not uploaded):'
$i = 0
foreach ($a in $adapters) {
    $i++
    $notes = @()
    if (Test-FFCandidate $a) { $notes += 'home-LAN candidate' }
    if ($a.IsVirtual) { $notes += "VIRTUAL ($($a.VirtualReason))" }
    if ($a.Status -ne 'Up') { $notes += $a.Status }
    if (-not $a.IPv4) { $notes += 'no IPv4' }
    if ($a.HasDefaultRoute) { $notes += 'default route' }
    $ip = '-'; if ($a.IPv4) { $ip = "$($a.IPv4)/$($a.PrefixLength)" }
    $desc = $a.Description; if ($desc.Length -gt 38) { $desc = $desc.Substring(0, 38) }
    Write-Host ("  [{0}] {1,-22} {2,-38} {3,-8} {4,-18} {5,-8} {6}" -f $i, $a.Alias, $desc, $a.Kind, $ip, $a.NetworkCategory, ($notes -join ', '))
}
if ($ListOnly) { exit 0 }

$candidates = @($adapters | Where-Object { (Test-FFCandidate $_) -and $_.HasDefaultRoute })
if ($interactive) {
    Write-Host ''
    Write-Host 'Choose the adapter that connects this PC to the SAME home router as your iPhone'
    Write-Host '(normally Wi-Fi or Ethernet with "default route"). vEthernet/WSL/Hyper-V/VPN adapters'
    Write-Host 'are not your home LAN unless you deliberately bridged it. Type Q to quit without saving.'
    $suggest = $null
    if ($candidates.Count -eq 1) {
        $suggest = [array]::IndexOf($adapters, $candidates[0]) + 1
        Write-Host "Suggested: [$suggest]. Press Enter to accept it, or type another number."
    } elseif ($candidates.Count -gt 1) {
        Write-Host "$($candidates.Count) adapters look like home-LAN candidates; please pick the one your iPhone shares."
    } else {
        Write-Host 'No obvious home-LAN adapter found. Check the PC is connected to your home network.'
    }
    while ($true) {
        $ans = Ask 'Adapter number'
        if (-not $ans -and $suggest) { $ans = "$suggest" }
        if ($ans -match '^\d+$' -and [int]$ans -ge 1 -and [int]$ans -le $adapters.Count) { $sel = $adapters[[int]$ans - 1]; break }
        Write-Host 'Enter a number from the list.'
    }
} else {
    $sel = $adapters | Where-Object { $_.Alias -eq $InterfaceAlias } | Select-Object -First 1
    if (-not $sel) { Write-Host "No adapter named '$InterfaceAlias'."; exit 3 }
}

if (-not $sel.IPv4) { Write-Host 'That adapter has no IPv4 address; connect it to the home network first.'; exit 3 }
if ($sel.IsVirtual -or $sel.Status -ne 'Up' -or -not (Test-FFCandidate $sel)) {
    Write-Host "Warning: this adapter is $($sel.Status), $(Get-FFIPv4Class $sel.IPv4), virtual=$($sel.IsVirtual) $($sel.VirtualReason)."
    if ($interactive) {
        if ((Ask 'Type YES to use it anyway') -cne 'YES') { Write-Host 'Not saved.'; exit 1 }
    } elseif (-not $AllowVirtual) { Write-Host 'Refusing without -AllowVirtual.'; exit 3 }
}

if ($interactive) {
    Write-Host ''
    Write-Host 'iPhone: Settings > Wi-Fi > (i) next to your home network > IP Address.'
    Write-Host 'Enter that address (or leave blank to add it later).'
    while ($true) {
        $PhoneIp = Ask 'iPhone Wi-Fi IP address'
        if (-not $PhoneIp -or (Test-FFIPv4 $PhoneIp)) { break }
        Write-Host 'That is not an IPv4 address like 192.168.1.60.'
    }
}
if ($PhoneIp) {
    if (-not (Test-FFIPv4 $PhoneIp)) { Write-Host 'Phone address is not a valid IPv4 address.'; exit 3 }
    if ($PhoneIp -eq $sel.IPv4 -or $PhoneIp -eq $sel.Gateway -or (Get-FFIPv4Class $PhoneIp) -in 'LOOPBACK', 'LINK_LOCAL', 'RESERVED') {
        Write-Host 'That is the PC, the router or a non-LAN address, not the iPhone address.'; exit 3
    }
    if (-not (Test-FFSameSubnet $sel.IPv4 $PhoneIp $sel.PrefixLength)) {
        Write-Host "Warning: the iPhone address is not in this adapter's subnet (/$($sel.PrefixLength)). Wrong adapter, guest network, or mistyped address?"
        if ($interactive) {
            if ((Ask 'Type YES to save anyway') -cne 'YES') { Write-Host 'Not saved.'; exit 1 }
        } elseif (-not $Yes) { exit 3 }
    }
}

$pcLan = [pscustomobject]@{
    interface_alias = $sel.Alias; interface_description = $sel.Description
    ipv4 = $sel.IPv4; prefix_length = $sel.PrefixLength; gateway_ipv4 = $sel.Gateway
}
Write-Host ''
Write-Host "PC_LAN:    $($sel.Alias)  $($sel.IPv4)/$($sel.PrefixLength)"
Write-Host "PHONE_LAN: $(if ($PhoneIp) { $PhoneIp } else { '(not set)' })"
if ($interactive) {
    if ((Ask 'Save these settings? [Y/n]') -match '^[nN]') { Write-Host 'Not saved.'; exit 1 }
} elseif (-not $Yes) { Write-Host 'Dry run; pass -Yes to save.'; exit 0 }

Save-FFConfig -Path $configPath -Existing (Read-FFConfig $configPath) -PcLan $pcLan -PhoneIPv4 $PhoneIp -Version $version | Out-Null
Write-Host "Saved: $configPath"
Write-Host 'Previous settings (if any) kept as config.local.json.bak.'
Write-Host 'Next: run scripts\doctor.cmd again and review SHARE_BACK.md.'
exit 0
