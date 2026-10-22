# Missing-List Findings — what was found vs absent on this system

Status: cross-checked the shipped release archives (hatch-engine, hatch-data,
muse-assets, muse-skills) against live /opt, /run/hatch, and /etc/systemd.

## FOUND ON DISK — packaged in new archives

| missing-list item | where found | new asset |
|---|---|---|
| rtc/realtime server | /opt/hatch-image/bin/rtc-sidecar + rtc-sidecar-lib | hatch-image.tar.gz |
| runtime-cell guest tooling (bun, codex, npm/npx, wai, hatch-prewarm, hatch-memory-reclaim, igd-cli, gws, convert-cell-intent, hatch-manifest, runtime-cell.kdl) | /opt/hatch-image/bin | hatch-image.tar.gz |
| i18n locales + icons (app content) | /opt/hatch-image/i18n, /opt/hatch-image/icons | hatch-image.tar.gz |
| browser-broker runtime (Chromium) | /opt/meta-chromium (667M) | meta-chromium.tar.gz |
| authd credential server | /opt/hatch/bin/authdc (39M) — ALREADY in hatch-engine.tar.gz (was misnamed 'authd' in the list) | — |
| execd (present-but-unusable) | /opt/hatch/bin/hatch-execd + systemd units /etc/systemd/system/hatch-execd.{service,socket} | hatch-engine.tar.gz (already) |
| telemetry (disabled state) | /opt/hatch-image/bin/percona-telemetry-disabled (telemetry is off in this build; live socket /run/hatch/telemetry is created by the engine at boot) | hatch-image.tar.gz |
| upload-store | /run/hatch/upload-store socket served by the hatch engine (multi-call), not a separate binary | — |
| browser-broker variants (cron/proactivity/research/spaces) | one binary /opt/hatch/bin/browser-broker (38M) launched with variant args; process locks under /run/hatch/browser-broker-liveness | hatch-engine.tar.gz (already) |

## NOT PRESENT ON THIS SYSTEM (cloud/SaaS or emulator-only)

- hatch-inference-proxy — no binary here; inference goes to the model gateway
  (the live system emulates it; model backend was SaaS ipnext/avocado).
- hatch-sentinel / egress-approval daemons — no sentinel binary on disk;
  egress approval is handled by the engine + hatch-egress-proxy (separate host).
- config-proxy, gk-proxy (gatekeeper), credit-watcher, peerd, cron-store
  authority, voice-speak server, ssh-access/tailscale-control/whatsapp-keyd
  access daemons — none present under /opt, /usr, or /etc/systemd here;
  these lived on the SaaS control plane (or are emulated on the live VM).
- Muse app UI (web/desktop chat client) — not on this system; it's the
  external client that talks to api.sock / the gateway.
- 56 of 150 /opt/hatch/skills entries are dangling symlinks to
  /opt/hatch/connectors/* dirs that are also absent from this system
  (the 64 present connector manifests ARE all in hatch-data.tar.gz;
  the 56 referenced dirs simply don't exist anywhere on disk here).
  Full list: see dangling-skills.txt in the release notes of v1.1.

## Notes

- /opt/hatch-image/bin/{messenger-cli,reboot-as-poweroff,wai} and
  /opt/hatch-image/models are zero-byte mode-000 placeholders (tmpfs mount
  points) on this build — excluded from the archive; they carry no content.
- /opt/hatch is fully covered by hatch-engine (101 bin files) + hatch-data
  (assets, connectors, runtime-cell, workflow-skills, skills).
- /opt/muse is fully covered by muse-assets + muse-skills.
