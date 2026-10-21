# SHARE_BACK template

The doctor generates the real file at `%LOCALAPPDATA%\FeedFilter\reports\SHARE_BACK.md`.
Open it, check it has no addresses, names or paths, then paste the whole file into the agent
conversation with the four lines below.

```text
Revision tested: <commit from the agent's reply, or the branch ZIP plus the date you downloaded it>
Step/command: <e.g. NEXT_STEPS step 8, scripts\doctor.cmd>
Phone observation: not tested (stage 1 has no phone test)
Proxy/VPN restored to Off after the test: not applicable (stage 1 changes no phone settings)
```

If no `SHARE_BACK.md` was generated, send this instead:

```text
Revision tested: <commit>
Step/command: <from NEXT_STEPS.md>
Result or exit code: <the "finished with exit code N" line, or what happened>
Phone observation: not tested
Relevant redacted error: <only the necessary lines; replace any addresses/names with XXX>
Proxy/VPN restored to Off after the test: not applicable
```

Never paste: `config.local.json`, `doctor-*.private.json`, anything from a `mitmproxy` folder,
passwords, certificates/keys, or captured traffic.
