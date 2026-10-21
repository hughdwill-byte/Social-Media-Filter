# iPhone Feed Filter Build Guide

Web coding agent + GitHub | Windows runtime + iPhone 13 | Home Wi-Fi first | Revised 20 October 2026

Build a filter for Instagram Reels and TikTok that preserves normal scrolling, hides user-selected themes and can later introduce controlled diversity. Start with your existing Windows PC and home Wi-Fi. The phone should be wireless during ordinary use; a cable is acceptable for initial developer setup if a fallback route needs it.

The first deliverable is a **feed-access result**, not an AI classifier. A trusted proxy can edit a feed only if the current app accepts interception and the relevant data can be decoded and changed. Certificate pinning may prevent that. A VPN or router does not remove the restriction. [2, 3]

Use these prompts with your **web-based coding agent connected to GitHub**. It writes the project in the repository and runs the checks available in its cloud environment. You download each revision, run its Windows launchers and perform the phone steps, then return a small redacted result. You do not need a local AI agent.

GitHub is where the code is developed and stored. The proxy/filter still runs on your Windows PC at home; putting code on GitHub does not put that cloud environment on your home network. Once the Windows program is running, the coding agent can be closed. The PC must remain awake for this route to work.

## 1 Start here

### Your first session

1. Create or select a GitHub repository for this project. A private repository is a sensible starting choice. Upload this file at its root as `iPhone_Feed_Filter_Build_Guide.md`; section 4 explains the browser steps.
2. Select/connect that repository in your web coding agent. Paste **Prompt 0** from section 3. It tells the agent to implement **Prompt 1**; do not paste every stage at once.
3. The agent creates the first code revision and `NEXT_STEPS.md`. Download that exact revision as a ZIP and extract it on Windows. Open the extracted folder containing `README.md` and `scripts`, rather than running files from inside the ZIP.
4. Follow `NEXT_STEPS.md` and run `scripts\doctor.cmd`. This first diagnostic must work without administrator access and without Python or mitmproxy already installed. Install mitmproxy when the report/instructions call for it, then repeat the diagnostic.
5. Review the generated **`SHARE_BACK.md`**, then paste its contents into the same web-agent conversation. Keep the private diagnostic and runtime directory on your PC. The agent fixes problems or prepares the next test revision.
6. Repeat that download → run → return-results cycle. Complete the Safari connection test in section 5, then the app-access test in section 6. Continue to filtering only after the access gates pass. Test Instagram and TikTok independently.

The initial guide contains instructions, not prebuilt filter software. Files such as `scripts/doctor.cmd` and `scripts/start-audit.cmd` are deliverables the agent must create in GitHub.

**A cloud test does not establish that the phone works.** When a stage needs your PC or iPhone, the agent must produce the runnable test and record `WAITING_FOR_USER_TEST`. It can continue independent code/documentation work, but cannot pass the next capability gate until you return evidence. No remote desktop, SSH, local AI agent or self-hosted GitHub runner is required.

### The handoff after every code revision

The agent must leave a short `NEXT_STEPS.md` and give the final commit/download link in its handoff reply after saving the code. The file must contain:

1. A release/version identifier, the working branch and what changed. The handoff reply identifies the exact committed revision to download.
2. The exact folder and one command or launcher to run, including whether administrator access is needed.
3. The expected output, how long the bounded test should take and when to stop.
4. Any iPhone actions, in order, and the rollback command/settings.
5. Where the generated `SHARE_BACK.md` is located and exactly what to return.

It should not ask you to edit source code, invent commands or interpret a large log. Installation, local network choices, certificate trust and observing the phone remain your actions. If a test fails, return its small summary; the agent changes the repository and supplies a new revision.

Use this reply format when the generated summary is not yet available:

```text
Revision tested: <commit supplied by the agent>
Step/command: <from NEXT_STEPS.md>
Result or exit code: <what actually happened>
Phone observation: <normal / failed / not tested, with a brief description>
Relevant redacted error: <only the necessary lines>
Proxy/VPN restored to Off after the test: <yes / no / not applicable>
```

Do not upload the entire Windows project folder, runtime directory or captured traffic as a shortcut. Section 4 explains how updates keep local settings and the trusted CA intact.

### Intended product

| Requirement | What the build must preserve |
| --- | --- |
| Familiar use | Normal app controls, playback, scrolling, comments, inbox, camera and microphone |
| Theme exclusions | Start with news and movie/TV excerpts; user defines the boundaries |
| Less targeting | Test bounded diversity among available allowed clips; no claim to know the platform's private engagement scores |
| Wireless operation | No cable or companion-app start ritual for ordinary home sessions |
| Automatic recovery | Handle lock/unlock, home Wi-Fi rejoin, PC restart and app updates without recurring force-quits |
| No jailbreak | Keep iOS unmodified; evaluate any modified social app separately |
| Initial spending | Free filter tools and existing equipment first; approximately A$50 ceiling for new project spending |

AI coding subscriptions or API usage can cost extra. Reuse an existing coding tool where possible; paid inference, new hardware and an Apple developer membership are not prerequisites for the first proxy test.

### What you do and what AI does

| You | Coding agent |
| --- | --- |
| Select the GitHub repository, download a revision and run its launchers | Edit repository files, run cloud/CI checks and provide a commit/PR or patch |
| Install applications, sign in directly and handle Windows/iPhone prompts | Generate diagnostics and exact instructions; diagnose the summaries you return |
| Select the home LAN locally and change iPhone network/certificate settings | Write listener/firewall checks and rollback tools for you to run |
| Scroll, compare the feed, label examples and judge disruption | Build adapters, rules, classifiers and selection policies from demonstrated evidence |
| Perform lock/rejoin/reboot tests and return reviewed results | Record user-reported live results separately from cloud/CI results |

## 2 Know how to restore normal use

Read this **before changing the phone's proxy settings**.

**Quick recovery:** on iPhone, open **Settings > Wi-Fi > the information button next to your home network > Configure Proxy > Off > Save**. Disconnect any experimental VPN if one was separately enabled. Then check an ordinary webpage. This restores direct routing; it does not remove the test certificate.

**End an audit:** switch the phone's proxy Off first, then stop the audit process on Windows. Close the local inspection browser window. Do not leave the phone pointing at a stopped proxy.

**Full cleanup:** remove the specific test profile under **Settings > General > VPN & Device Management**, and verify its extra root trust is gone under **General > About > Certificate Trust Settings**. Run the agent's generated cleanup instructions to remove only this project's firewall rule, startup task and temporary captures. The web agent cannot remove them remotely. Keep source code and test notes unless you want them deleted.

Do not turn off Windows Firewall, weaken system-wide execution policy or remove unrelated certificates to fix this project.

## 3 Give the AI its permanent brief

Use this at the start of the first coding session. In later sessions, use the resume prompt in section 13.

### Prompt 0 Project brief

```text
You are implementing my iPhone feed-filter experiment as a web-based coding agent working in the connected GitHub repository. Read iPhone_Feed_Filter_Build_Guide.md and applicable repository instructions. Write the code and documentation, run the checks your environment supports, and commit the work or open a PR using your available GitHub tools. If write access is unavailable, produce the actual files/patch and exact upload instructions; do not claim a commit exists. Do not stop at a proposed design.

You have no direct access to my Windows PC, iPhone, router, home LAN or installed applications. Your cloud OS, tools, IP address and resources are not mine. Do not claim to inspect or change my devices. Package Windows launchers and short manual instructions for all actions that require them. No local AI agent, remote desktop, SSH, self-hosted runner or cloud-to-home tunnel is required.

Goal: use Instagram Reels and TikTok normally on an unjailbroken iPhone, initially an iPhone 13 with user-reported iOS 26.6.1. Hide user-selected themes, initially news and movie/TV excerpts. Later test bounded diversity that may increase with an accurately observed session. Preserving ordinary app interaction is the highest priority. Home Wi-Fi-only operation is acceptable. Everyday use must be wireless and require no session-start ritual. My Windows PC is the runtime host. Prefer free tools and no new hardware.

Start with the home-network HTTPS response-editing capability test. Treat routing, readable native feed data, accepted mutations, classification and everyday operation as separate gates. Track each app/build independently. Do not assume a public personal-feed API or invent private endpoints, schemas, device observations or successful tests. A VPN does not remove certificate pinning. Do not build a classifier before feed access is established.

Use current primary documentation. Where installed Windows help is needed, generate a local check for me to run; never substitute your cloud installation for mine. Keep the implementation small: Windows launchers, mitmproxy addons, simple configuration and reports. Keep credentials, CA private keys, pairing records, tokens, signed URLs and raw traffic out of chat, GitHub, CI and shared logs. Keep the inspection UI on loopback and upstream TLS verification enabled. Do not inspect inbox content or generate views, likes, follows or comments.

Create PROJECT_STATE.md, TEST_RESULTS.csv, NEXT_STEPS.md and SHARE_BACK_TEMPLATE.md. Give each handoff a matching version identifier in code and generated reports, usable without Git installed; report the final commit/download link in your reply after committing. Record the tested revision, relevant versions, command/test ID, status, evidence source and blocker. Evidence environments must distinguish CLOUD_FIXTURE, WINDOWS_CI, USER_WINDOWS and USER_IPHONE. Use PASS, FAIL, NOT_RUN or BLOCKED for tests; record WAITING_FOR_USER_TEST as the current workflow state when a device observation is missing. Cloud fixtures and a hosted Windows CI runner never prove my PC/phone works. Record a user-reported result as such; leave genuinely missing fields unknown.

Keep runtime state under a stable, user-local directory, default %LOCALAPPDATA%\FeedFilter, outside downloaded code folders. Use its config.local.json and fixed mitmproxy CA/config subdirectory across revisions. Ignore any accidental local copies, private diagnostics, captures and keys in source control. Build an allowlisted local summary exporter before asking me to share data. Show only its reviewed SHARE_BACK.md to the model; unsupported formats must remain local until a safe summary method exists.

At every device gate, finish the runnable code and available tests first. Then give one short numbered batch of user actions through NEXT_STEPS.md: exact revision/download, launcher, expected output, phone steps, rescue path and minimal result to return. Wait for that evidence before dependent work. You may continue independent utilities, tests and documentation. Do not ask me to write code or install a local agent.

Use GitHub-hosted Windows CI if available within existing permissions/quota for meaningful launcher/quoting tests; otherwise record it as not run. Never require my home devices to be reachable from CI. No real captures, home CA or device signing material belong in Actions artifacts. Do not enable paid resources or publish a server as a workaround.

On malformed or unsupported traffic, preserve the original response and mark filtering unavailable; hard exclusions are not active during that fallback. Do not substitute a timer, browser viewer or intrusive auto-skip product without identifying the scope change. Keep Windows changes narrow and reversible; provide launchers and cleanup commands for me to run, not claims that you ran them here. Do not change global execution policy, disable security tools or expose a control UI to the LAN.

Now implement Prompt 1 only. Commit/package that first diagnostic handoff, state what you actually tested, and leave device checks WAITING_FOR_USER_TEST.
```

### Prompt 1 Prepare the repository and Windows diagnostic handoff

```text
Implement stage 1 in this GitHub repository. Inspect the repository and your cloud development environment only. Generate scripts/doctor.cmd and any supporting Windows-native diagnostic code so I can inspect my actual Windows machine. The first diagnostic must run with built-in Windows tools, no administrator access and no preinstalled Python/mitmproxy. It may write its own local report files but must not change network, firewall, trust or startup settings.

Create README.md, START_HERE.md, PROJECT_STATE.md, TEST_RESULTS.csv, NEXT_STEPS.md, SHARE_BACK_TEMPLATE.md, config.example.json and .gitignore. Create focused tests for the diagnostic parser/exporter and launcher argument handling where your tools permit. Supply a bounded optional Windows CI check if supported; record the real CI outcome rather than assuming it ran. Avoid Docker, WSL, Xcode, local models and developer-device tools at this stage.

The user-run doctor must report Windows version/architecture, relevant shell/tool versions, mitmweb availability/help compatibility, candidate physical LAN adapters/routes, network profile, ports 8080/8081 and basic resources needed later. Missing tools must produce a useful report, not a crash. Do not dump environment variables, unrelated documents, network secrets or full process command lines. Keep actual addresses and paths in a private report. Generate a separate allowlisted SHARE_BACK.md containing versions, statuses and redacted errors with consistent PC_LAN/PHONE_LAN labels instead of machine/account identifiers.

Provide a local configuration launcher that lets me select the actual home LAN adapter and enter the iPhone Wi-Fi address after installation. Do not silently select a VPN/WSL/virtual adapter or require uploading actual LAN addresses to make the code work. If the choice is ambiguous, explain it on my screen and ask me to select locally. Store settings at %LOCALAPPDATA%\FeedFilter\config.local.json, and keep mitmproxy CA/config at %LOCALAPPDATA%\FeedFilter\mitmproxy. Never commit generated runtime data or create/export a real user CA in the cloud.

Return the committed branch/commit or actual patch, an exact-revision download method, and a short NEXT_STEPS.md: extract the code, run scripts\doctor.cmd, install the official Windows mitmproxy package if missing, rerun doctor/configuration, review and return SHARE_BACK.md. Include paths relative to the downloaded folder and state any required privilege. Make the launchers work with spaces in paths. Do not claim my environment is inspected or phone connectivity works until I return results. Set WAITING_FOR_USER_TEST.
```

**Pass:** the code exists in the selected repository, you have run its diagnostic/configuration on Windows, and your returned results establish tool readiness and a locally selected home LAN. Repository setup or cloud diagnostics alone do not pass this stage.

## 4 Set up GitHub, download the code and identify the network

### You select the repository and upload this guide

1. In GitHub, create a repository named `FeedFilter`, or choose an existing suitable repository you own. Start private if you prefer. Keep passwords and private runtime material out of it regardless of visibility.
2. Upload this guide at the repository root with its exact filename. On an existing repository page, use **Add file > Upload files**, choose the file and commit the addition. If GitHub proposes a branch/PR, complete that process or select that branch in the agent so the guide is visible. [1]
3. In your web coding agent, select/connect the repository using that tool's normal repository controls. Authorise access to this repository as needed; do not paste a GitHub token into chat.
4. Paste Prompt 0. The agent should write the first diagnostic code, save its changes and return a branch/commit or PR link. It cannot inspect Windows before you run the diagnostic.
5. If the agent cannot write to GitHub, have it provide actual downloadable source files or a patch plus upload instructions. A claim that it would create the files is not a deliverable.

### You download and run each revision on Windows

Use the agent's exact-commit archive link when supplied. Alternatively, open its repository branch on GitHub, choose **Code > Download ZIP**, and record the commit shown for the revision you are testing. A branch can move; a commit identifies the code contents for the test. You can download a working branch without first merging it into the default branch. [20]

1. Save and extract the ZIP using File Explorer. Use an ordinary folder such as `Documents\FeedFilter\revisions\test-001`; use a new folder for each later revision.
2. Open the extracted project folder containing `README.md` and `scripts`. Open `NEXT_STEPS.md`, then run its launcher. For the first handoff this should be `scripts\doctor.cmd`. If a window closes before you can read it, open a terminal in that folder and run the same launcher there.
3. Review the generated shareable summary before pasting it into the web agent. The program must print its exact report location. Keep the private report and runtime directory on the PC.
4. The agent updates the code in GitHub and tells you which revision to download next. The agent cannot see your new local files until you return the requested result.

You do not need Git, GitHub Desktop or a local coding agent for this download-and-run workflow. Windows still needs to execute the generated filter code; a web agent cannot act as the home proxy.

### Keep runtime files stable when code changes

The agent must use a stable runtime directory outside the extracted ZIP folders:

| Local location | Purpose | Return to the agent? |
| --- | --- | --- |
| `%LOCALAPPDATA%\FeedFilter\config.local.json` | Actual addresses and selected local settings | No; return the summary statuses |
| `%LOCALAPPDATA%\FeedFilter\mitmproxy` | This installation's persistent CA/config, including its private key | Never |
| `%LOCALAPPDATA%\FeedFilter\reports` | Local diagnostics and generated reports | Only the reviewed `SHARE_BACK.md` or an explicitly requested sanitized fixture |
| Extracted revision folder | Downloaded code, example config and instructions | Code already belongs in GitHub; do not upload the whole working folder |

Before changing revisions, turn the phone's proxy/VPN Off and stop the old process. Download/extract the new revision, then run its doctor and next-step launcher. The launcher must reuse the runtime directory and existing CA; do not install a different certificate merely because the source ZIP changed. Keep the last working revision available for rollback. An intentional CA replacement requires a separate explained phone-trust update.

### What cloud tests can establish

The web agent can run unit tests, synthetic fixture checks, parsers, simulations and packaging checks in its available environment. A GitHub-hosted Windows runner can additionally exercise Windows launchers, but it is a separate cloud machine. It does not establish your home route, installed certificate, native-feed compatibility or real-phone performance. [21]

CI is optional when permissions or quota prevent it. The agent should use modest bounded jobs within your existing allowance, report skipped checks and avoid enabling charges. Do not install a self-hosted runner or expose your home proxy to the internet to make cloud tests reach the phone. Your local test summaries supply that evidence.

### You install mitmproxy

1. Open [the official mitmproxy installation page](https://docs.mitmproxy.org/stable/overview/installation/).
2. Follow **Windows** and use its installer.
3. Open a **new** PowerShell window after installation and run:

```powershell
mitmweb --version
```

The command should print a version. If it is not found, run the generated doctor and return its redacted error. The agent must provide a targeted local check or launcher correction to locate the executable or fix the current session's path. Do not reinstall everything immediately. The Windows installer supplies mitmweb; you do not need to manage Python dependencies just for this first test. [4]

### You connect the devices

1. Connect iPhone to your home Wi-Fi. The PC may use Wi-Fi or Ethernet on the same reachable LAN.
2. Avoid a guest network that isolates devices from each other.
3. On iPhone, open **Settings > Wi-Fi > information button for the connected network**. Record the phone's **IP Address**. Record the iOS version/build from **General > About**, and the installed Instagram and TikTok versions where available. If an app version is unclear, have the agent show you how to obtain it.
4. On Windows, use the LAN address displayed and selected by the user-run diagnostic/configuration launcher from Prompt 1. The phone's proxy **Server** will use the PC address, not the phone address, the router address or `127.0.0.1`.
5. Set the Windows network profile to **Private** only if this is your trusted home network. The usual Windows 11 path is **Settings > Network & internet > Wi-Fi or Ethernet > the connected network's properties**. If your edition differs, let the agent locate the equivalent setting.

Enter actual addresses only in the local configuration launcher; it saves `%LOCALAPPDATA%\FeedFilter\config.local.json`. You need not paste the addresses into the web agent. They can change later; section 10 covers making them stable.

## 5 Prove the phone can use the proxy

### Prompt 2 Create the audit launcher and a small firewall change

```text
Implement stage 2 in GitHub after my returned stage-1 summary establishes local tool readiness. Create scripts/start-audit.cmd with modes positive-control, host-inventory and inspect-approved-hosts. Load the PC/phone addresses from the stable local runtime config at execution time; never hard-code your cloud address or require my actual LAN addresses in the repository. Reuse the dedicated CA/config directory. Keep the web UI on loopback port 8081 and the proxy on the selected LAN port 8080, subject to local port checks.

Positive-control must intercept HTTPS only for example.com:443; pass other HTTPS through unchanged. Do not enable flow-file/HAR persistence. An inspection view filter is not an interception boundary. For host-inventory, collect only CONNECT destination host/port and time using documented hooks; do not export headers, paths, query strings or bodies. Account for HTTP separately. Inspect-approved-hosts must take exact observed destinations from local config, not guessed platform endpoint lists.

Check current documented option syntax and code/quoting with available cloud tools. Generate a Windows preflight that validates the installed tool/help and startup errors on my machine. Produce scripts to add/remove one narrow inbound firewall rule for the proxy, using the selected LAN destination, phone source and Private profile. Show the exact proposed rule locally; administrator access is only for the firewall step if required. Do not disable the firewall, create broad rules or run privileged cloud commands as if they changed my PC.

Test launcher/config/error handling with fixtures and Windows CI where available. Record those environments separately. Package local start/status/stop checks and a safe report exporter. NEXT_STEPS.md must tell me how to download this revision, run the firewall/preflight steps, start positive-control, configure the phone using section 5, verify Safari HTTPS, turn proxy Off and return SHARE_BACK.md. Print local listener/UI details and a three-step rescue reminder on my PC. Keep any UI token local. Leave gate A NOT_RUN until my observation arrives.
```

### You allow the phone to reach port 8080

Use the agent's tailored command. For reference, this is the intended shape; **replace both example addresses before running it** in an Administrator PowerShell window:

```powershell
$FeedLanIp = '192.168.1.50'
$FeedPhoneIp = '192.168.1.60'
New-NetFirewallRule -Name 'FeedFilterAudit8080' -DisplayName 'FeedFilter audit 8080' -Direction Inbound -Action Allow -Protocol TCP -LocalAddress $FeedLanIp -LocalPort 8080 -RemoteAddress $FeedPhoneIp -Profile Private
```

Removal, when no longer needed:

```powershell
Remove-NetFirewallRule -Name 'FeedFilterAudit8080'
```

Microsoft documents these rule parameters. If the PC is managed and denies the change, report that to the agent; do not work around school/employer policy. [5]

### You start the positive control

Download/extract the revision produced by Prompt 2, follow its `NEXT_STEPS.md`, run the local launcher and leave it running. A reference PowerShell command is below. Use the agent's generated launcher once available; the reference is for checking the design, not a second simultaneous proxy.

```powershell
$FeedLanIp = '192.168.1.50'
$FeedConfDir = Join-Path $env:LOCALAPPDATA 'FeedFilter\mitmproxy'
mitmweb --listen-host $FeedLanIp --listen-port 8080 --set web_host=127.0.0.1 --set web_port=8081 --set "confdir=$FeedConfDir" --allow-hosts '^example\.com:443$'
```

Replace the example PC address. Keep this same configuration directory throughout the experiment so the trusted CA does not silently change. Open the local web-UI URL printed by mitmweb; if it includes a token, keep it local. The current installed help/options are authoritative if syntax changes. [6, 7]

### You configure the iPhone

1. Open **Settings > Wi-Fi > information button for home Wi-Fi > Configure Proxy**.
2. Choose **Manual**.
3. Set **Server** to the PC LAN address and **Port** to `8080`.
4. Leave proxy authentication off for this narrowly scoped LAN test; tap **Save**.
5. In Safari, open **http://mitm.it**. The onboarding page should load. If it does not, stop here and use the troubleshooting table in section 12.
6. From that onboarding page, download the iOS certificate profile for this running proxy instance.
7. Install the downloaded profile under **Settings > Profile Downloaded** or **General > VPN & Device Management**, following the displayed prompts.
8. Open **General > About > Certificate Trust Settings**, and enable full trust for that test root. Enter the phone passcode on the phone if asked. A manually installed profile is not automatically trusted for TLS. [8]
9. In Safari, open **https://example.com**. Confirm the page loads without a certificate warning and that the proxy can show its HTTP response body. Tell the agent only whether this worked and any relevant error, not a complete traffic export.

Installing the test root permits inspection of connections that accept it. Use your own proxy instance and keep its private key off chat and source control. The profile's trust is device-wide even though this test routes through home Wi-Fi.

**Pass gate A:** a phone request reaches the proxy, and the HTTPS positive-control response is readable. This proves the test setup, not access to Instagram or TikTok.

After this short test, switch the phone's proxy **Off** until the agent is ready for the app audit.

## 6 Establish real app feed access

### Prompt 3 Inventory and classify the access result

```text
Implement stage 3 in GitHub using my returned gate A evidence. Preserve the working positive-control configuration. Prepare user-run host-inventory mode with HTTPS passed through, then a brief exact-host interception test for destinations I observed during one app's public video-feed use. Host choices must be selected/stored locally. Keep the CA directory unchanged. Do not require login/logout, inspect private messages or guess feed endpoints from old examples.

Package a short local audit sequence with baseline, public-feed scroll interval and end time. Correlate repeated intervals to distinguish probable app destinations from background traffic. Build local field-name/type summaries and a deterministic allowlisted sanitizer before requesting any fixture. Redact cookies, authorization, query tokens, signed URLs and device/account IDs; generate synthetic replacements preserving needed relationships. For an unknown format, keep it local and first supply tools/instructions to establish what can safely be shared. Do not ask for raw HAR/flow files or assume a sanitizer can handle unknown binary data. I inspect locally and return only reviewed summaries or deliberately selected sanitized fixtures.

From that returned evidence, record each app/build's routing, client TLS acceptance, decoded relevant response, candidate identification and mutation-not-yet-tested status. Mark missing results NOT_RUN. Handle JSON, compression or binary formats according to observed evidence. Readable analytics, a CDN video or a website response does not establish a mutable native feed.

Diagnose bypass separately from TLS rejection and opaque data. Use my positive-control and targeted pass-through comparisons; do not assert pinning solely because an app fails to load. If regular proxy settings are bypassed, prepare the bounded documented WireGuard test in Prompt 3R; it is not a pinning bypass. Otherwise stop at a supported blocker and write ROUTE_DECISION.md. Return the code revision and NEXT_STEPS.md, not a claim that you have run my audit. Wait for the local result before passing gate B.
```

### You perform the app audit

1. Start with **one** app. Keep its existing signed-in session.
2. Download the agent's audit revision and run its host-inventory launcher on Windows; re-enable the same phone proxy settings. The web agent cannot start it remotely.
3. Use the normal public Reels/For You surface for a short recorded interval. Leave the inbox and account-management screens alone.
4. Return the generated reviewed summary with start/end times, time zone and whether playback behaved normally. Repeat the same interval if needed to distinguish background traffic.
5. Follow its targeted-host inspection instructions, then repeat the public-feed test. You should not have to sign in through a third-party page.
6. Switch proxy Off when the audit ends. Raw traffic stays on your PC. Supply the AI only the generated sanitized summaries it needs.

If a response is cached, one diagnostic app restart can help identify fresh traffic. A design that requires force-quitting for each ordinary session is not acceptable.

### Choose the next route from the result

| Observed result | Next step |
| --- | --- |
| No phone connection reaches the listener | Fix LAN address, firewall or device isolation; this is not evidence of pinning |
| Safari succeeds but the app bypasses the HTTP proxy | Let AI prepare the limited routing test below |
| App reaches the proxy but rejects targeted TLS interception | Restore pass-through, document the evidence and evaluate section 11 |
| TLS works but candidate data is unavailable or opaque | Investigate the observed codec/schema; do not invent a working adapter |
| A native feed response with candidate records is decoded | Continue to Prompt 4 to test whether editing is accepted |
| One platform passes and the other fails | Build the passing platform first; keep support claims separate |

### Optional routing test if the app bypasses the HTTP proxy

mitmproxy documents a WireGuard mode for external devices. This changes the route, not the target app's certificate rules. [2]

#### Prompt 3R Test an alternative route

```text
My returned evidence indicates the HTTP-proxy route was bypassed. Implement a bounded mitmproxy WireGuard-mode LAN test in the repository using current documentation. Generate a user-run installed-help/preflight check where needed. Keep the existing CA directory and restrict inspection to the positive-control host, then exact locally observed target destinations. Preserve the prior config. Package exact local startup, narrowly scoped firewall, verification and shutdown steps.

Generate tunnel keys/configuration only on my PC; never in the repository or cloud, and do not ask me to paste them into chat. Give instructions to transfer configuration directly to the official iPhone WireGuard client. Do not expose the server with router port forwarding or a public cloud relay.

NEXT_STEPS.md must guide me through Safari HTTPS positive control, the native-feed routing test, IPv4/IPv6 checks where supported, and restoring my previous route. The tool's local report must separate observed routing from TLS/feed results. Do not claim this fixes pinning or captures every transport. Record only the results I return and leave unperformed device tests NOT_RUN.
```

You install the iPhone client linked from [WireGuard's official installation page](https://www.wireguard.com/install/), import the generated configuration directly and enable it only for the test. Use the same proxy CA and repeat Safari before the app. Finish by turning the tunnel off and restoring the previous route. Treat generated tunnel keys as secrets.

**Pass gate B:** current native-app candidate records are decoded and associated with the tested feed. If this gate fails after diagnosis, skip to section 11; do not build a classifier around guessed traffic.

## 7 Prove one feed edit and build the adapter

### Prompt 4 Implement and test a minimal adapter

```text
Implement stage 4 in GitHub only for an app/build with user-supplied gate B evidence. Build a versioned adapter from reviewed sanitized schema evidence. If that evidence is missing or insufficient, generate the local schema-summary/fixture tools and wait; do not invent a platform schema. First support no-change pass-through. In a decoded/re-encoded path preserve the supported semantic structure and protocol headers; when disabled/unsupported forward original bytes without needless re-encoding.

Create synthetic fixtures preserving necessary relationships. Preserve IDs, playback URLs, signed fields, pagination, continuation tokens, required counts and organic/ad boundaries according to observed semantics. Do not guess field repairs. Account for compression, length, status and streaming; do not buffer large video bodies just to filter a metadata response.

Add a temporary debug rule that removes one explicitly selected candidate or swaps two adjacent organic candidates in one identified response. Keep it scoped and reversible. Package a local experiment that lets me identify the intended candidates on the PC without uploading private values. Explain how the displayed change will be established; one absent clip alone is weak proof. Do not generate fake engagement or replay authenticated requests to manufacture candidates.

Run focused cloud fixture tests for no-op preservation, malformed/unknown schema, pagination and empty pools. On unsupported input/error, preserve the original response and mark filtering unavailable. Use aggregate/redacted diagnostics. Fixtures are not live integration evidence.

Commit/package this revision and a short NEXT_STEPS.md for my proxy-Off, no-change, mutation and restored-normal comparisons, with the exact summary to return. Wait for my observed playback/navigation/pagination results before gate C. Record a blocker if accepted mutation cannot preserve normal use.
```

### You verify it in the real app

1. Run the no-change mode and compare normal feed loading, scrolling and back navigation with proxy Off.
2. Run the agent's single-response mutation experiment.
3. Record whether the feed changed as predicted, whether the next page loads and whether returning from comments/profiles still works.
4. Disable the debug mutation and confirm normal behaviour returns.
5. Repeat enough to rule out caching or ordinary recommendation variation; let the agent specify a controlled comparison using identifiable test candidates.

**Pass gate C:** a repeatable, demonstrated native-feed edit with coherent playback and pagination. The adapter must also have a working bypass. Only now start the filtering product.

## 8 Build theme filtering

### You define the first labels

Use these starting boundaries, then change them to match what you want:

| Theme | Starting definition | Decide explicitly |
| --- | --- | --- |
| News | Reporting or commentary about current public events | Include politics? Sports results? Historical explainers? |
| Movie and TV excerpts | Footage from a film or television programme presented as a clip | Include trailers, reviews, reactions, memes and interviews? |

Start with one theme. Collect a small labelled set of examples that the working integration can actually observe, including ambiguous cases and wanted clips that might be confused with the unwanted theme. A practical first sample is 50-100 examples; it is for development, not proof of population-level accuracy. Keep a held-out subset that is not used for rule/model tuning.

### Prompt 5 Add rules and an optional classifier

```text
Implement stage 5 in GitHub using the proven adapter, my gate C results and my theme definitions. Begin with available captions, hashtags, creator rules and transparent text rules. Package observation-only mode before hiding content. Metadata may not describe the full video.

Create a local labelling launcher and labelled CSV format, with duplicate control and a held-out evaluation split. Provide a local evaluator reporting precision, recall, missing/unknown evidence, errors by theme and delay. Keep private viewing examples local by default. I can return aggregate metrics and deliberately reviewed sanitized error examples. Never claim evaluation has happened before I run it; distinguish any synthetic developer tests.

If rules are inadequate, select a small suitable local text/image model based on the Windows resources in my returned doctor summary. Generate the benchmark for my PC and ask for its safe performance summary. A cloud/CI benchmark is not a measurement of my PC or phone experience. Explain what can be inspected before native rendering. Measure end-to-end delay, not only inference time; add frames/audio only when acquisition has been demonstrated. Keep inference outside the proxy event loop with bounded queues, timeouts and caching; do not download full clips on the critical path by default.

Keep default inference free/local. Offer cloud inference only as a separate configured option with scoped data and estimated cost. Enable the first theme after I accept the measured result. Disabled/unknown/timeout paths must report inactive or partial filtering; do not claim zero unwanted exposure. Preserve hard exclusions within successful filtering and define empty-pool behaviour.

Return the revision and NEXT_STEPS.md for labelling, evaluation and a short live comparison, including exact launchers and rollback. Record gate D from my results, never from the presence of classifier code.
```

### You check the experience

Label mistakes, compare proxy On/Off, and note visible waiting, repeated clips, missing wanted clips or broken controls. Let the agent refine the classifier from those findings. An accurate model that repeatedly stalls the app is unsuitable for this brief.

**Pass gate D:** the selected theme is measurably filtered in the real feed with acceptable false removals and added delay. Do not promise that unlabelled or later-revealed content is always caught.

## 9 Add controlled diversity only when it can be implemented honestly

First keep theme exclusions fixed. Then test a separate diversity policy. Increasing variety may increase or decrease use; do not treat it as an established way to reduce doomscrolling.

A response adapter can choose only among candidates it obtains. If all candidates are about one topic, shuffling them does not create topic diversity. Discarding each theme with the same probability also preserves the distribution in expectation.

### Prompt 6 Implement a bounded selection policy

```text
Implement stage 6 in GitHub as an optional module, default off during the theme-filter comparison. Hard exclusions come first. Then select from available eligible candidates using a configurable mixture of original order and underrepresented user-allowed themes/creators. Keep a relevance floor, avoid repeats and preserve playback/pagination. Do not claim proprietary engagement scores or fabricate candidates.

Before time progression, document and locally test its actual runtime observation source. Request count/prefetch timestamps do not establish watched clips or active duration. If an accurate unobtrusive signal is unavailable, run cloud offline session simulations and implement only fixed-diversity live mode. Mark progressive-by-watched-time unavailable. A manually started debug clock is not an everyday implementation.

If the user-run measurement verifies a clock, implement a bounded increasing weight and documented reset rule. Keep parameters configurable and label starting values experimental. Test scarce pools, mixed themes, exclusions, reproducible seeded simulation and delivered diversity rather than only changed order. Distinguish simulated outcomes from live results.

Prepare a user-run comparison of filtering alone versus filtering plus diversity with timers unchanged/off. Supply simple local outcome recording for unwanted session duration, satisfaction, repetition and disruption. Do not imply increased variety reduces scrolling until measured. Commit/package the code and NEXT_STEPS.md; wait for my results before gate E and disable/change a policy that increases unwanted use.
```

### You run the comparison

Choose which allowed topics still make the feed worthwhile. Try the two modes on comparable occasions and record whether a session felt longer than you wanted. Report app switching or compensating with more scrolling later. Do not judge success from variety alone.

**Pass gate E:** the selection policy changes accepted content as intended, preserves exclusions and improves the user's outcome without sacrificing normal interaction. If timing is unobservable, retain fixed diversity or theme filtering and label the missing feature.

## 10 Make home operation automatic

Do this after feed editing and basic filtering work. Automatic routing around a non-working filter has no value.

### Prompt 7 Build unattended home operation and recovery

```text
Implement stage 7 in GitHub around the configuration already demonstrated on my devices. Package Windows launch/stop/status tools, a same-user logon task installer with bounded restarts, and exact uninstall commands for me to run. Resolve user identity locally at execution time, never from the cloud account. Keep the existing runtime directory, CA and adapter. Do not run as SYSTEM or recreate a CA. Distinguish logon startup from before-logon service operation.

Prepare manual router DHCP-reservation instructions based on a nonsecret model/UI description if needed. Read actual adapter addresses only in local tools. Separate screen-off from PC sleep. Do not require router firmware changes or new hardware.

Compare per-Wi-Fi proxy/PAC with any justified VPN-on-demand route. Keep interception scoped and unrelated traffic unmodified. PAC DIRECT fallback/PAC-unreachable options are candidate mechanisms, not proven recovery. Package tests for the actual apps: cached PAC, proxy down, half-alive proxy and model timeout. A cloud/localhost health result never proves phone filtering or route recovery.

Provide local status for supported app/build, ready/partial/unavailable and last user-reported live evidence. No status screen should interrupt scrolling. Use a circuit breaker for known bad runtime/adapter states; label original-response fallback unfiltered. Cached native candidates may escape a fresh-response filter.

Generate NEXT_STEPS.md with the exact local install/uninstall commands, phone settings, lifecycle matrix and safe outcome exporter. I run the lock/rejoin/reboot/update tests; you record returned evidence. If repeated prompts, force-quits, session buttons, capture rituals or a cable are needed for ordinary use, record UX_FAILED. Do not claim traffic stops after leaving Wi-Fi without that observation. Gate F remains pending until the user tests pass.
```

### You stabilise the home setup

1. Keep the PC plugged in and awake while the filter is expected to work. The display may turn off. In Windows power settings, adjust **plugged-in sleep** as appropriate; a locked PC can remain running, while a sleeping PC cannot serve the filter.
2. Follow the agent's router-specific instructions to reserve the PC's LAN address. The iPhone Wi-Fi details show the router address; use your router's normal local administration interface. Enter its password yourself, not into AI chat. If you do not control the router, tell the agent.
3. Ensure the configured phone-source firewall address remains correct. If it changes, run the agent's generated local configuration/rule-update steps and retest; the web agent cannot update your firewall itself. A changed phone address can look like a broken filter.
4. Apply the final per-network settings generated by the agent. A Wi-Fi profile can carry proxy settings; Apple also documents a limited fallback when its PAC file is unreachable. This does not guarantee recovery from every failure. [9, 10]
5. Log in to Windows after a reboot if the chosen startup task runs at logon. Do not assume it runs before logon. [11]

### You perform the everyday acceptance tests

Run the supplied local test checklist and return its reviewed summary. The web agent then records it in `TEST_RESULTS.csv` as user-reported device evidence; unperformed tests remain `NOT_RUN`. Include the tested code revision and actual app/iOS versions.

| Test | Required observation |
| --- | --- |
| Take phone out, unlock and open the app | No extra session steps; filtering operates on supported fresh candidates |
| Lock, wait and unlock | No repeated trust prompts, cable or forced app restart |
| Leave home Wi-Fi and return | Intended routing resumes; stale cached candidates do not create a false protection claim |
| Stop the proxy / put PC to sleep | Ordinary connectivity recovers through the tested fallback; filter status is unavailable |
| Keep proxy alive but stall classifier | Bounded delay and labelled unfiltered fallback; no endless loading |
| Restart PC, then log in | Correct process/config/CA return without duplicate listeners |
| Reboot iPhone | Normal first unlock and app use recover without special daily setup |
| Open inbox, comments, camera and microphone functions | No unintended action or loss of those functions; no requirement to send a message or call someone just for testing |
| Scroll past a page boundary and reopen an existing session | Pagination works; filtering does not depend on clearing the app each visit |
| Update an app or change network address | Revalidation or honest unavailable status, not a silent claim of compatibility |

For a first everyday pilot, try 30 normal openings across several days and record failures. That is a small engineering check, not proof of a clinical or general behavioural effect. Decide acceptable delay and filtering error thresholds before judging the pilot.

**Pass gate F:** useful cable-free home operation with reliable recovery and acceptable normal use. If automatic recovery fails, keep the system a supervised prototype and fix that failure before ordinary deployment.

## 11 Branches if the main route cannot meet the brief

### Branch B Modified native client

Choose this before accepting an intrusive skip-based product if familiar interaction remains the deciding factor. A change inside a compatible client could filter before rendering and eventually run on the phone, including away from home. The missing prerequisite may be a trustworthy modifiable build, not an AI prompt.

#### Prompt B1 Assess and implement only a verifiable client route

```text
Evaluate the no-jailbreak modified-client route using our recorded blocker and current primary project sources. Work in GitHub/cloud only. Identify obtainable trustworthy source/build inputs, how modifications load on stock iOS, what can be built with your available cloud tools, what Windows can do and what specifically requires macOS/Xcode or another service. A macOS CI runner does not automatically provide a compatible social-app build or signing capability. Do not recommend a prepatched IPA solely on marketing claims.

Write CLIENT_ROUTE.md with app/build, required artifacts, obtainable inputs, signing/entitlements, account effects, update burden, costs and stop conditions. Distinguish source audit, publisher claim, CI build and user-verified device execution. If a necessary input is missing, name it and stop that implementation; do not invent hooks/endpoints or claim a sideloadable result.

Only with verified inputs, produce a minimal inspectable modification at the candidate-to-render boundary preserving the familiar UI and record relationships. Reuse policy code, starting with debug removal and a default-disabled filter. Build only where your environment actually supports it. Leave user account credentials, pairing/signing secrets and device trust steps local; do not request them in chat or GitHub. If a local build step is unavoidable, package its exact instructions and prerequisites rather than asking for a local agent.

Commit/package source changes and NEXT_STEPS.md for the verified build/install route. I perform signing/trust/device tests. Phone-only operation requires my demonstration with the PC off the runtime path. Test playback/navigation, camera/microphone, relaunch, reboot and expiry/refresh. An install or CI build alone does not prove filtering, consumer distribution or successful renewal.
```

#### You install only after an actual compatible build exists

Have the agent select and verify a current signing route. One documented option is SideStore's Windows-compatible initial setup. Follow its [prerequisites](https://docs.sidestore.io/docs/installation/prerequisites) and [installation guide](https://docs.sidestore.io/docs/installation/install), including the version-appropriate iOS instructions. [12, 13]

The manual sequence is: install the official prerequisite tools, connect the phone by USB, trust the computer, use the documented installer with your own Apple Account, complete developer trust/Developer Mode prompts on the phone where required, and configure the documented on-phone refresh workflow. Enter account details directly in the tool, not in AI chat. The agent should then give instructions for the specific verified test build.

Free personal provisioning normally needs renewal after seven days. A refresh mechanism may reduce recurring cable use, but expiry and failed refreshes still need tests. [14] Sideloading does not create the feed modification and does not establish App Store approval.

**Pass:** the actual modification changes the feed on this phone, its everyday functions remain usable, and installation/renewal burden meets your requirements. Otherwise record the blocker.

### Branch C Wireless screen observer

Use this as a capability experiment or optional measurement layer. It sees content after display; a skip may be noticeable. It does not supply an off-screen catalogue or direct control of the server recommender.

#### Prompt C1 Establish wireless observation and one action

```text
Prepare a separate no-jailbreak Windows/iPhone observer experiment in the repository, preserving the proxy setup. Use current primary documentation to assess pymobiledevice3 CoreDevice screenshot/stream/HID support first, then Appium with a preinstalled signed WDA if needed. Generate isolated dependency setup and local installed-help checks. Do not claim cloud discovery of my phone. Identify Developer Mode, disk-image, pairing, driver and signing prerequisites, including unavailable build inputs.

Package minimal one-time USB/trust instructions and local diagnostic launchers. They must test uncabled LAN discovery and a supported observation on my PC. Add an explicit local confirmation before exactly one selected test swipe in a supported public-feed state; no remote action should be implied by my chat message. Keep control endpoints on the trusted host. Collect a small safe result on reachability, actual app/build and coexistence with my gestures. No autonomous classification or repeated swipes yet.

Supply local tests for stream release, camera/microphone, lock/unlock, rejoin and reboot. If streaming blocks ordinary functions, assess a less intrusive method. A phone that must stay unlocked or requires capture restart each visit fails unattended normal-use requirements. Distinguish CoreDevice requirements from WDA signing; do not pretend Windows has an Xcode build path. Run only meaningful mocked/cloud checks here, then commit/package NEXT_STEPS.md and await my actual device results.
```

#### You perform initial pairing and the wireless test

1. Connect iPhone to the PC with a cable, unlock it and accept **Trust This Computer** on the phone.
2. Follow the agent's current Developer Mode/device-service instructions if required. Reboot and confirm on the phone when prompted. This is standard developer setup, not jailbreaking.
3. Run the generated Windows setup diagnostic for pairing, driver compatibility and enabling Wi-Fi connections. Current project documentation describes these prerequisites, but they must work on this PC. [15, 16]
4. Disconnect the cable, keep both devices on the reachable home LAN and run the wireless discovery/observation test again. Return its reviewed result; a connection while USB is attached does not establish cable-free operation.
5. Open the public feed, then use the generated local confirmation to allow one test swipe. Confirm that exactly the intended movement occurred and your own gestures still work; return that observation to the web agent.
6. Open camera/microphone functions locally and verify the observer releases them. CoreDevice streaming documentation describes conflicts with those resources. [17]
7. Test lock/rejoin/reboot before considering automatic actions.

Appium documents limited Windows support, including a preinstalled or externally managed WDA requirement; its default Xcode build/startup path is unavailable there. [18]

#### Prompt C2 Add theme decisions with strict action control

```text
Continue in GitHub only after my C1 results demonstrate acceptable observation/action behaviour. Reuse the theme definitions/evaluator. Package local classification without actions first. Then allow a user-enabled bounded test that skips only a stable identified clip in the exact supported feed state. Invalidate stale decisions on every transition, verify the result and stop after unexpected transitions or a short rejected run. Never act in inbox, comments, keyboard, system prompts or another app.

Do not send likes, follows, comments or messages. Create local measurements for first-unwanted-frame-to-transition delay, false/consecutive skips, gesture collisions, battery cost and resource conflicts. Cloud mocks may test decision control, not actual timing or iPhone behaviour. I run the short test using ordinary navigation; do not force-relaunch the app to make it work.

Content-dependent rejection helps only when alternatives arrive; uniformly random skipping is not diversification. Do not claim before-display blocking or upstream reranking. Return code revision, NEXT_STEPS.md, stop/rollback and a safe result format. If my reported experience is noticeably worse, mark UX_FAILED and retain only research/measurement mode.
```

**Pass:** useful wireless local filtering that you judge unobtrusive. If it fails that standard, do not treat it as the requested product just because the automation works.

## 12 Troubleshooting without rebuilding everything

| Symptom | Check first |
| --- | --- |
| `mitmweb` is not recognised | Open a new terminal; locate installer/executable and PATH |
| Listener cannot bind | Correct physical LAN address, port conflict, address changed |
| Phone cannot load `http://mitm.it` | Server/port values, running listener, Private-profile rule, phone-source IP, guest-network isolation |
| HTTP works but `https://example.com` fails | Exact installed CA, full trust, same configuration directory, proxy's upstream connectivity |
| Safari control passes but app fails | App route, targeted TLS failure, custom transport or opaque app data; not automatically pinning |
| Many responses are readable but no feed is identified | You may be seeing analytics, playback files or website traffic; gate B remains unpassed |
| A filter change has no visible effect | Cached candidates, wrong surface/response, wrong build adapter or an unaccepted edit |
| Empty/looping feed or pagination failure | Disable mutation, preserve original response, inspect adapter invariants |
| Works only after force-quitting | Cache/session integration is incomplete; do not accept for normal use |
| Internet breaks when PC sleeps | Manual proxy has no proven working bypass; restore proxy Off and fix stage 7 |
| Wireless developer phone disappears | Pairing/driver discovery, LAN isolation, lock/reboot lifecycle; diagnose before changing the classifier |
| AI says everything passed but you have not tested the phone | Correct provenance/status; cloud fixtures and Windows CI cannot establish live compatibility |
| Web agent tries to inspect Windows but reports Linux/cloud IPs | Ask it to generate/run cloud checks only there and provide doctor.cmd for your PC |
| New ZIP cannot find settings or asks for a different CA | Stop; fix stable runtime-directory reuse before trusting another certificate |
| You downloaded code but the launcher is missing | Check the agent's branch/commit and extracted project root; do not assume the default branch has its changes |
| Agent is waiting for a local file it cannot access | Return the reviewed SHARE_BACK.md contents; leave private/raw files local |

### Prompt 8 Diagnose a failure

```text
Read PROJECT_STATE.md, the last relevant TEST_RESULTS.csv entry and the reviewed summary I pasted from my local test. Confirm which code revision I actually downloaded. You have no access to my local files/device unless I supply a safe result. Diagnose the smallest failed layer; preserve the last working configuration. Explain up to three plausible causes, then run discriminating cloud checks or package the smallest local diagnostic that separates them. Do not reinstall unrelated tools or rewrite the project.

Use redacted errors/aggregate diagnostics. Do not request raw HAR/flows, passwords, CA keys, signing or pairing files. If the summary is insufficient, change the local exporter/check and provide an exact short test batch rather than requesting the entire runtime directory.

Implement the fix in GitHub, run relevant available tests and return the new revision plus NEXT_STEPS.md. Tell me exactly how to stop the old process, download/extract the fix, reuse the runtime/CA, repeat the failed test and any affected earlier control, then return the new summary. Update live evidence only after I report the result; otherwise remain WAITING_FOR_USER_TEST.
```

## 13 Resume work and finish the prototype

### Prompt 9 Resume in a new AI session

```text
You are a web coding agent in the connected GitHub repository, not on my Windows PC. Read iPhone_Feed_Filter_Build_Guide.md, applicable repository instructions, PROJECT_STATE.md, ROUTE_DECISION.md if present, NEXT_STEPS.md and recent TEST_RESULTS.csv entries. Use reviewed summaries already supplied in this conversation/repository; never read/request raw captures or secrets.

Summarise the implemented branch/commit, supported app/build, last user-verified gate, blocker and next action in five lines. Distinguish cloud/CI results from my device observations. Continue useful repository work and preserve working code. If the next step depends on Windows/iPhone evidence, give the exact revision/download and one short local action batch with the safe summary to return; record WAITING_FOR_USER_TEST rather than pretending you inspected my computer. Do not require a local AI agent.
```

### Prompt 10 Audit and package the working result

```text
Review the repository prototype against this guide and the user-reported evidence. Verify claims for feed mutation, unknown-schema fallback, theme errors, timing, routing and recovery. Separate CLOUD_FIXTURE, WINDOWS_CI, USER_WINDOWS, USER_IPHONE and unperformed checks. A script existing or CI passing does not establish a device capability. Audit code/config/logging and scoped cleanup without requesting secret contents.

Run relevant focused checks and fix defects. Commit/package a usable Windows source release with USER_SETUP.md, START_HERE.md, NEXT_STEPS.md, rollback, pinned dependencies, compatibility record and a version identifier that works in a downloaded ZIP without Git installed. Include one-command launch/status/stop where possible, safe summary export and exact unavoidable phone actions. Keep runtime settings/CA outside extracted releases and test update/rollback logic with dummy data. Do not include real captures, credentials, keys, fake adapters or a time blocker presented as feed control.

Return the actual branch/commit/PR and exact-revision download link. If a ZIP/build artifact cannot be generated with available tools, say so and provide the supported source-download path and installation steps; do not claim a nonexistent binary. Document which checks I must run and what actually works on the tested phone, what remains conditional, recurrence/renewal and maintenance. Do not deploy a public server or distribute modified platform binaries as part of packaging. Do not mark the final user acceptance complete until its device results exist.
```

### Final acceptance

The prototype is useful when a supported feed is changed as intended, the unwanted themes are reduced with known errors, ordinary app functions remain usable, and cable-free home operation recovers without recurring rituals. A successful installation, a synthetic demo or a running local status page is not sufficient.

Phone-only operation and operation away from home are later milestones. Expand to them only after a demonstrated integration exists. Extend to YouTube and computers after the primary Reels/TikTok experiment has delivered value.

## 14 Primary references

Checked 20 October 2026. These establish tool capabilities and setup mechanisms; the project's runtime results must come from the gates above.

1. GitHub, [Adding a file to a repository](https://docs.github.com/en/repositories/working-with-files/managing-files/adding-a-file-to-a-repository).
2. mitmproxy, [Proxy modes](https://docs.mitmproxy.org/stable/concepts/modes/).
3. mitmproxy, [Certificates and pinning limitations](https://docs.mitmproxy.org/stable/concepts/certificates/).
4. mitmproxy, [Windows installation](https://docs.mitmproxy.org/stable/overview/installation/).
5. Microsoft, [New-NetFirewallRule](https://learn.microsoft.com/en-us/powershell/module/netsecurity/new-netfirewallrule).
6. mitmproxy, [Options](https://docs.mitmproxy.org/stable/concepts/options/).
7. mitmproxy, [Selective interception and ignored domains](https://docs.mitmproxy.org/stable/howto/ignore-domains/).
8. Apple, [Trust manually installed certificate profiles](https://support.apple.com/en-au/102390).
9. Apple, [Wi-Fi profile proxy and PAC settings](https://developer.apple.com/documentation/devicemanagement/wifi).
10. Mozilla, [Proxy Auto-Configuration](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_PAC_file).
11. Microsoft, [Starting an executable when a user logs on](https://learn.microsoft.com/en-us/windows/win32/taskschd/starting-an-executable-when-a-user-logs-on).
12. SideStore, [Prerequisites](https://docs.sidestore.io/docs/installation/prerequisites).
13. SideStore, [Installation](https://docs.sidestore.io/docs/installation/install).
14. Apple, [Developer account and Personal Team limits](https://developer.apple.com/help/account/basics/about-your-developer-account).
15. pymobiledevice3, [Developer tunnels and Wi-Fi transport](https://github.com/doronz88/pymobiledevice3/blob/master/docs/guides/ios17-tunnels.md).
16. pymobiledevice3, [Windows installation and driver notes](https://github.com/doronz88/pymobiledevice3/blob/master/docs/installation.md).
17. pymobiledevice3, [CoreDevice streaming and HID recipes](https://github.com/doronz88/pymobiledevice3/blob/master/docs/guides/cli-recipes.md).
18. Appium, [Non-macOS hosts](https://appium.github.io/appium-xcuitest-driver/latest/guides/non-macos-hosts/) and [Remote XPC tunnels](https://appium.github.io/appium-xcuitest-driver/latest/guides/remotexpc-tunnels-real-devices/).
19. mitmproxy, [Addon examples](https://docs.mitmproxy.org/stable/addons/examples/), [event hooks](https://docs.mitmproxy.org/stable/api/events.html) and [HTTP message API](https://docs.mitmproxy.org/stable/api/mitmproxy/http.html).
20. GitHub, [Downloading source code archives](https://docs.github.com/en/repositories/working-with-files/using-files/downloading-source-code-archives).
21. GitHub, [GitHub-hosted runners](https://docs.github.com/en/actions/concepts/runners/github-hosted-runners).

Adapter, classification, diversity and recovery prompts are implementation requirements for this project. They are not claims that the platform supports an undocumented interface or that the intended reduction in scrolling is already established.
