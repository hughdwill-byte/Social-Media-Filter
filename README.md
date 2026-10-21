# FeedFilter (iPhone feed-filter experiment)

Version: see `VERSION` (currently `0.1.0-stage1`). Plan and capability gates: `iPhone_Feed_Filter_Build_Guide.md`.

**Status:** stage 1 only, a read-only Windows diagnostic and a LAN configuration launcher.
Nothing here intercepts traffic, filters a feed or changes phone settings. No capability gate has
passed. Native feed access for Instagram/TikTok is **unknown** until device evidence exists.

New here? Open `START_HERE.md`, then `NEXT_STEPS.md`.

## Layout

| Path | Purpose |
| --- | --- |
| `scripts\doctor.cmd` | Read-only diagnostic. Writes a private report and an allowlisted `SHARE_BACK.md`. No admin. |
| `scripts\configure.cmd` | Lets you pick the home LAN adapter and enter the iPhone Wi-Fi address locally. No admin. |
| `scripts\lib\FeedFilter.psm1` | Shared helpers: classification, redaction, share-back exporter, config. |
| `tests\run-tests.ps1` | Assert-based tests (parser, exporter, config, doctor smoke). |
| `.github\workflows\windows-ci.yml` | Optional bounded launcher check on a GitHub-hosted Windows runner. |
| `PROJECT_STATE.md`, `TEST_RESULTS.csv` | Gate status and evidence, with the source of each result. |

## Runtime data (stays on your PC, outside the downloaded folder)

| Location | Contents | Share? |
| --- | --- | --- |
| `%LOCALAPPDATA%\FeedFilter\config.local.json` | Selected adapter, PC and iPhone LAN addresses | No |
| `%LOCALAPPDATA%\FeedFilter\mitmproxy` | Future mitmproxy CA/config (stage 2+). Not created in stage 1 | Never |
| `%LOCALAPPDATA%\FeedFilter\reports` | `doctor-*.private.json` (private) and `SHARE_BACK.md` | Only the reviewed `SHARE_BACK.md` |

Every revision reuses this directory, so downloading a new ZIP does not change settings or the CA.

## Safety rules the code follows

- Stage 1 runs only read-only queries. It never changes network, firewall, certificate trust,
  startup or global execution policy. `-ExecutionPolicy Bypass` on the launcher line applies to that
  one process.
- `SHARE_BACK.md` is built from an allowlist. Known private values (addresses, adapter names, user and
  PC names, paths) become labels such as `PC_LAN_1`, `PHONE_LAN` and `GATEWAY`. A leak guard withholds
  the file if any of those values remain.
- Evidence is labelled `CLOUD_FIXTURE`, `WINDOWS_CI`, `USER_WINDOWS` or `USER_IPHONE`. Cloud and CI
  results never count as proof that your PC or phone works.

## Developer tests

```
pwsh -NoProfile -File tests/run-tests.ps1        # any OS with PowerShell 7
powershell -NoProfile -File tests\run-tests.ps1  # Windows PowerShell 5.1
```
