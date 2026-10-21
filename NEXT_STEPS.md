# NEXT_STEPS: FeedFilter 0.1.0-stage1

**Workflow state: WAITING_FOR_USER_TEST** (stage 1: Windows tool readiness + local LAN selection)

- **Release/version:** `0.1.0-stage1` (shown by the doctor and printed in `SHARE_BACK.md`)
- **Branch:** `claude/peaceful-hamilton-fyjcns` in `hughdwill-byte/Social-Media-Filter`
- **What changed:** this is the first handoff. It adds a read-only Windows diagnostic (`scripts\doctor.cmd`),
  a LAN configuration launcher (`scripts\configure.cmd`) and an allowlisted `SHARE_BACK.md` exporter.
- **Exact revision:** the agent's handoff reply gives the commit and its ZIP link
  (`https://github.com/hughdwill-byte/Social-Media-Filter/archive/<commit>.zip`). Prefer that link.
  The branch ZIP also works, but it moves when new commits arrive:
  https://github.com/hughdwill-byte/Social-Media-Filter/archive/refs/heads/claude/peaceful-hamilton-fyjcns.zip
- **Administrator access:** not needed for any step. Do not use "Run as administrator".
- **Time:** about 10 minutes, plus the mitmproxy install. Each doctor run takes 1 minute or less.
- **Phone:** look up one value only (step 6). **Do not** change the iPhone proxy or install any profile in this stage.

## Steps (on your Windows PC)

1. Download the ZIP from the commit link in the agent's reply and save it to `Downloads`.
2. Right-click the ZIP, then choose **Properties**. If an **Unblock** checkbox appears at the bottom, tick it and click **OK**.
   This affects only this file and stops Windows from blocking the launchers.
3. Extract it with File Explorer to `Documents\FeedFilter\revisions\test-001`. Open the inner folder that contains
   `README.md` and `scripts`. Do not run anything from inside the ZIP.
4. Double-click `scripts\doctor.cmd`.
   **Expected:** a black window shows `FeedFilter doctor 0.1.0-stage1`, then a summary, and Notepad opens `SHARE_BACK.md`.
   On a first run without mitmproxy, expect `TOOLS_MITMWEB NOT_READY` and `LAN_SELECTION NOT_SELECTED`. This is normal.
   The last line is `doctor finished with exit code 0`. Press any key to close.
   If the window closes too fast to read, open **Command Prompt**, run `cd /d "%USERPROFILE%\Documents\FeedFilter\revisions\test-001\<inner folder>"`, then `scripts\doctor.cmd`.
5. If step 4 showed `TOOLS_MITMWEB NOT_READY`, install mitmproxy from the official page
   https://docs.mitmproxy.org/stable/overview/installation/ (Windows section, use its installer).
   Close any open command windows afterwards. The next steps need a fresh window.
6. On the iPhone, open **Settings > Wi-Fi**, tap the **(i)** next to your home network and note the **IP Address**.
   Change nothing on the phone. Make sure the PC is on the same home network, not a guest network.
7. Double-click `scripts\configure.cmd`. It lists this PC's network adapters on your screen only.
   Type the number of the adapter connected to your home router (usually Wi-Fi or Ethernet marked
   `home-LAN candidate, default route`), or press Enter to accept the suggestion. Then type the iPhone IP address from step 6 and confirm with Enter.
   **Expected:** `Saved: ...\FeedFilter\config.local.json`. Type `Q` at any prompt to quit without saving.
   If it warns about a VIRTUAL adapter or a subnet mismatch, stop. Answer anything except `YES`, and mention the warning when you report back.
8. Double-click `scripts\doctor.cmd` again.
   **Expected:** `TOOLS_MITMWEB READY`, `LAN_SELECTION SELECTED`, `PORTS_8080_8081 FREE`.
   `NET_PROFILE_SELECTED` should be `PASS` (Private). A `WARN` there means Windows treats the network as Public.
   Do not change that yet. Report it, and stage 2 will give exact steps.
9. Notepad shows `SHARE_BACK.md`. Its location is `%LOCALAPPDATA%\FeedFilter\reports\SHARE_BACK.md`, and the doctor prints the full path.
   Read it and delete anything that looks like an address, a name or a path. Paste it into the agent conversation
   with the four lines from `SHARE_BACK_TEMPLATE.md`. Stop there; stage 1 is complete on your side.

## What to return

Only the reviewed `SHARE_BACK.md` plus the four template lines. Keep `doctor-*.private.json` and `config.local.json` on the PC.
If something failed before a `SHARE_BACK.md` appeared, use the fallback format in `SHARE_BACK_TEMPLATE.md`.

## Rollback / cleanup (stage 1 changed no system settings)

- Nothing on the iPhone was changed. The proxy should still be **Off**.
  (Rescue path for later stages: **Settings > Wi-Fi > (i) > Configure Proxy > Off > Save**.)
- To undo a LAN selection, run `scripts\configure.cmd` again. The previous file is kept as
  `%LOCALAPPDATA%\FeedFilter\config.local.json.bak`. To restore it, run this in Command Prompt:
  `copy /y "%LOCALAPPDATA%\FeedFilter\config.local.json.bak" "%LOCALAPPDATA%\FeedFilter\config.local.json"`
- To remove all stage-1 data, run this in Command Prompt:
  `rmdir /s /q "%LOCALAPPDATA%\FeedFilter\reports"` and `del "%LOCALAPPDATA%\FeedFilter\config.local.json*"`
- mitmproxy can be uninstalled from **Settings > Apps** if you abandon the project. Stage 1 created no certificate.

## Troubleshooting

| You see | Do |
| --- | --- |
| "running scripts is disabled" / "not digitally signed" | Delete the extracted folder, unblock the ZIP (step 2), extract again. If it persists, return the `EXEC_POLICY` row or the error line. Do not change the system execution policy. |
| `MITMWEB_FOUND WARN installed but not on this window's PATH` | Sign out and back in, then rerun doctor. If it still warns, return the file; this is not a blocker. |
| `mitmweb` errors or `MITMWEB_HELP FAIL` | Return the file as is. Do not reinstall yet. |
| `LAN_SELECTION STALE` | The PC address changed. Rerun `configure.cmd`, then `doctor.cmd`. |
| No `home-LAN candidate` in configure | Connect the PC to the home Wi-Fi/Ethernet (not a VPN), then retry. Return the doctor file if it persists. |
