# PROJECT_STATE

- **Version:** 0.1.0-stage1
- **Branch:** claude/peaceful-hamilton-fyjcns
- **Workflow state:** WAITING_FOR_USER_TEST (stage 1 doctor/configure results from the user's Windows PC)
- **Last user-verified gate:** none
- **Blocker:** user-run stage-1 evidence (see NEXT_STEPS.md)
- **Windows CI:** run 39551519924 PASS (WINDOWS_CI only; does not prove the user PC). Launcher fix for an inherited PSModulePath verified by run 39552005308 PASS.

## Gates (from the build guide)

| Gate | Meaning | Instagram | TikTok | Evidence |
| --- | --- | --- | --- | --- |
| Stage 1 | Tools ready on user PC, home LAN selected locally | n/a | n/a | WAITING_FOR_USER_TEST |
| A | iPhone reaches proxy; HTTPS positive control (example.com) readable | n/a | n/a | NOT_RUN |
| B | Native feed candidate records decoded | NOT_RUN | NOT_RUN | none |
| C | Repeatable accepted feed edit with coherent playback/pagination | NOT_RUN | NOT_RUN | none |
| D | Theme measurably filtered with acceptable errors/delay | NOT_RUN | NOT_RUN | none |
| E | Diversity policy improves user outcome | NOT_RUN | NOT_RUN | none |
| F | Cable-free home operation with reliable recovery | NOT_RUN | NOT_RUN | none |

No claim is made that native feed access, interception or filtering works. The code contains no
interception, endpoint list, adapter or classifier.

## Known facts

| Fact | Source |
| --- | --- |
| iPhone 13, iOS 26.6.1 | User-reported in the guide; not yet observed |
| Windows version, tools, adapters | Unknown until the doctor's SHARE_BACK.md is returned |
| Instagram / TikTok app versions | Unknown |

## Decisions

- Launchers are `.cmd` wrappers around built-in Windows PowerShell 5.1 (`-NoProfile -ExecutionPolicy Bypass -File`, process scope only).
  They need no Python, mitmproxy or admin rights. The scripts are ASCII and stay 5.1-compatible.
- Runtime state lives in `%LOCALAPPDATA%\FeedFilter` (config, reports, future `mitmproxy` confdir), outside downloaded revisions.
- Share-back output uses an allowlist, and a leak guard checks it against known private values.
- mitmweb readiness is judged by the content of `--version`, `--help` and `--options`. `mitmweb --help` exits 1 on 12.2.3, so its exit code is not used.
- Adapter auto-classification flags WSL/Hyper-V/VPN/VM adapters as virtual. The user always confirms the selection locally.
  A bridged Hyper-V external switch can legitimately carry the home LAN, so virtual adapters are allowed after an explicit `YES`.
- Noted for stage 2: mitmproxy's `block_global` defaults to true, and the phone uses a private LAN address, so this should not block it. Verify on the device.

## Next (after the stage-1 result arrives)

Prompt 2: `scripts\start-audit.cmd` (positive-control / host-inventory / inspect-approved-hosts), the narrow firewall rule add/remove scripts, and the gate A Safari test.
